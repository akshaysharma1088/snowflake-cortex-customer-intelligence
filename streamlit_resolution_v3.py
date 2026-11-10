"""Read-only 200-case Snowflake Cortex resolution-evidence dashboard.
Source: CORTEX_CI_DEMO.APP.V_RESOLUTION_V3_COMPARISON
No AI calls are issued on refresh. Use existing observed v3 outputs.
"""
import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Cortex Resolution Intelligence · 200 Cases", page_icon="❄️", layout="wide")

st.title("❄️ Cortex Resolution Intelligence")
st.caption("Resolution-aware customer support analytics  |  200 synthetic examples  |  Snowflake Cortex AI_CLASSIFY v3.0")
st.info("Research demonstration: the 200 cases are built from 20 text templates across 10 product contexts. Metrics are exact agreement with constructed reference labels, NOT real-world model accuracy.")

@st.cache_data(ttl=300)
def load_predictions():
    session = get_active_session()
    return session.sql("""
        SELECT CASE_ID, PRODUCT, DOMAIN, COHORT, TRANSCRIPT,
               GOLD_RESOLUTION, GOLD_DISSATISFACTION, VERSION,
               RUN_AT, CORTEX_RESOLUTION, EXACT_MATCH,
               TO_VARCHAR(RESOLUTION_RAW) AS RESOLUTION_RAW_TEXT
        FROM CORTEX_CI_DEMO.APP.V_RESOLUTION_V3_COMPARISON
        WHERE CASE_ID LIKE 'R3-%'
        ORDER BY CASE_ID
    """).to_pandas()

try:
    df = load_predictions()
except Exception as exc:
    st.error("Unable to read V_RESOLUTION_V3_COMPARISON. Confirm sql/09_resolution_v3_200_benchmark.sql ran successfully and the Streamlit role has SELECT access.")
    st.exception(exc)
    st.stop()

if df.empty:
    st.warning("The v3 comparison view is empty. Run the 200-case SQL experiment first.")
    st.stop()

df["GOLD_RESOLUTION"] = df["GOLD_RESOLUTION"].fillna("missing")
df["CORTEX_RESOLUTION"] = df["CORTEX_RESOLUTION"].fillna("NO_PREDICTION")
df["CORRECT"] = df["GOLD_RESOLUTION"] == df["CORTEX_RESOLUTION"]
df["HAS_PREDICTION"] = df["CORTEX_RESOLUTION"] != "NO_PREDICTION"

labels = ["confirmed_resolved", "reported_unresolved", "disputed", "unknown"]
pretty = {
  "confirmed_resolved": "Confirmed resolved",
  "reported_unresolved": "Reported unresolved",
  "disputed": "Disputed",
  "unknown": "Unknown",
  "NO_PREDICTION": "No prediction",
}

with st.sidebar:
    st.header("Filters")
    selected_categories = st.multiselect(
        "Reference resolution",
        options=labels,
        default=labels,
        format_func=lambda v: pretty.get(v, v),
    )
    domains = sorted(df["DOMAIN"].dropna().unique().tolist())
    selected_domains = st.multiselect("Domain", domains, default=domains)
    show_errors = st.checkbox("Only mismatches", value=False)
    st.caption("Filters change the case explorer, not the overall benchmark KPIs.")

filtered = df[
    df["GOLD_RESOLUTION"].isin(selected_categories)
    & df["DOMAIN"].isin(selected_domains)
].copy()
if show_errors:
    filtered = filtered[~filtered["CORRECT"]]

total = len(df)
predicted = int(df["HAS_PREDICTION"].sum())
correct = int(df["CORRECT"].sum())
accuracy = (100 * correct / predicted) if predicted else 0

k1, k2, k3, k4 = st.columns(4)
k1.metric("Synthetic cases", f"{total:,}")
k2.metric("Cortex predictions", f"{predicted:,}/{total:,}")
k3.metric("Exact matches", f"{correct:,}")
k4.metric("Observed agreement", f"{accuracy:.2f}%")
st.caption("Metrics above are calculated from the full v3 result set; template-based synthetic examples are not independent real-world observations.")

left, right = st.columns([1, 1])
with left:
    st.subheader("Outcomes by reference class")
    counts = (
        df.groupby("GOLD_RESOLUTION", as_index=False)
          .agg(Cases=("CASE_ID", "size"), Correct=("CORRECT", "sum"))
    )
    counts["Category"] = counts["GOLD_RESOLUTION"].map(pretty)
    counts["Incorrect"] = counts["Cases"] - counts["Correct"]
    st.bar_chart(counts.set_index("Category")[["Correct", "Incorrect"]])
with right:
    st.subheader("Confusion matrix")
    matrix = pd.crosstab(df["GOLD_RESOLUTION"], df["CORTEX_RESOLUTION"])
    matrix = matrix.reindex(index=labels, columns=labels + (["NO_PREDICTION"] if "NO_PREDICTION" in matrix.columns else []), fill_value=0)
    matrix.index = [pretty.get(v, v) for v in matrix.index]
    matrix.columns = [pretty.get(v, v) for v in matrix.columns]
    st.dataframe(matrix, use_container_width=True)

st.subheader("Case explorer")
st.caption(f"Showing {len(filtered)} cases after filtering · Model output is stored in Snowflake; dashboard refresh does not rerun Cortex")
st.dataframe(
    filtered[["CASE_ID", "PRODUCT", "DOMAIN", "GOLD_RESOLUTION", "CORTEX_RESOLUTION", "CORRECT", "TRANSCRIPT"]],
    hide_index=True,
    use_container_width=True,
)
if filtered.empty:
    st.info("No cases match the current filters.")
else:
    selected_case = st.selectbox("Inspect a case", filtered["CASE_ID"].tolist())
    detail = filtered.loc[filtered["CASE_ID"] == selected_case].iloc[0]
    st.write("**Customer message**")
    st.write(detail["TRANSCRIPT"])
    x, y, z = st.columns(3)
    x.metric("Reference", pretty.get(detail["GOLD_RESOLUTION"], detail["GOLD_RESOLUTION"]))
    y.metric("Cortex prediction", pretty.get(detail["CORTEX_RESOLUTION"], detail["CORTEX_RESOLUTION"]))
    z.metric("Exact match", "Yes" if detail["CORRECT"] else "No")
    with st.expander("Raw Cortex response and run metadata"):
        st.code(str(detail["RESOLUTION_RAW_TEXT"]), language="json")
        st.write("Run version:", detail["VERSION"])
        st.write("Run timestamp:", detail["RUN_AT"])

st.divider()
st.caption("Public educational prototype · Synthetic labels authored during dataset creation · No real customer data · Not an independent model benchmark")
