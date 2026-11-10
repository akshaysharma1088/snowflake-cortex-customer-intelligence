"""Read-only Streamlit in Snowflake dashboard. No inference on page refresh."""
import streamlit as st
st.set_page_config(page_title="Cortex Customer Intelligence", page_icon="❄️", layout="wide")
st.title("❄️ Cortex Customer Intelligence")
st.caption("Synthetic support data only · Cortex enrichment runs separately")
@st.cache_data(ttl=300)
def get_data():
    from snowflake.snowpark.context import get_active_session
    session = get_active_session()
    return session.sql("""
      SELECT CONVERSATION_ID, CREATED_AT, CHANNEL, PRODUCT, TRANSCRIPT,
             GOLD_SENTIMENT, GOLD_ISSUE, GOLD_UNRESOLVED,
             SENTIMENT_RAW, EXTRACTION_RAW, ISSUE_CLASSIFICATION_RAW
      FROM CORTEX_CI_DEMO.APP.V_CONVERSATION_INTELLIGENCE
      ORDER BY CREATED_AT DESC
    """).to_pandas()
try:
    df = get_data()
except Exception as exc:
    st.error("Could not load demo view. Run setup/load/views and check grants.")
    st.code(type(exc).__name__)
    st.stop()
if df.empty:
    st.info("No demo conversations loaded yet.")
    st.stop()
channels = sorted(df["CHANNEL"].dropna().unique().tolist())
chosen = st.sidebar.multiselect("Channel", channels, default=channels)
df = df[df["CHANNEL"].isin(chosen)]
total = len(df)
enriched = int(df["SENTIMENT_RAW"].notna().sum())
negative = int((df["GOLD_SENTIMENT"] == "negative").sum())
a, b, c = st.columns(3)
a.metric("Conversations", total)
b.metric("Cortex-enriched", enriched)
c.metric("Negative (synthetic labels)", negative)
st.subheader("Issue mix (synthetic labels)")
st.bar_chart(df["GOLD_ISSUE"].value_counts())
st.subheader("Conversation explorer")
cols = ["CONVERSATION_ID","CREATED_AT","CHANNEL","PRODUCT",
        "GOLD_SENTIMENT","GOLD_ISSUE","GOLD_UNRESOLVED"]
st.dataframe(df[cols], hide_index=True, use_container_width=True)
selected = st.selectbox("Inspect a conversation", df["CONVERSATION_ID"].tolist())
row = df[df["CONVERSATION_ID"] == selected].iloc[0]
st.text_area("Transcript", row["TRANSCRIPT"], height=150, disabled=True)
with st.expander("Raw Cortex output (audit and review)"):
    st.json({"sentiment": str(row["SENTIMENT_RAW"]),
             "extraction": str(row["EXTRACTION_RAW"]),
             "issue_classification": str(row["ISSUE_CLASSIFICATION_RAW"])})
st.caption("The synthetic gold labels are illustrative, not measured Cortex accuracy.")


# Exploratory diagnostic only: this is a lexical *candidate* screen, not BIRD.
# Operates on whole transcript fields, so speaker attribution is not guaranteed.
import re
st.subheader("Polite but potentially unresolved · exploratory screen")
st.caption("Keyword-based candidates only—not verified dissatisfaction or Cortex/BIRD predictions. Full transcripts may include agent messages.")
pattern_polite = r"(?i)\b(thanks?|thank you|appreciate|please)\b"
pattern_unresolved = r"(?i)(still (?:not|cannot|fails?|does not work)|not (?:working|resolved|fixed)|no fix|issue is still open|cannot (?:sign in|access)|not appeared yet)"
if not df.empty:
    candidates = df[df["TRANSCRIPT"].str.contains(pattern_polite, regex=True, na=False) &
                    df["TRANSCRIPT"].str.contains(pattern_unresolved, regex=True, na=False)]
    st.metric("Candidate conversations", len(candidates))
    st.dataframe(candidates[["CONVERSATION_ID", "GOLD_UNRESOLVED", "TRANSCRIPT"]],
                 hide_index=True, use_container_width=True)
