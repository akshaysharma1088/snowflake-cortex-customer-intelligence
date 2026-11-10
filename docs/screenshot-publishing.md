# Publishing the live Snowflake dashboard screenshots

The source screenshots were captured in the project owner's **actual Streamlit in Snowflake trial session**, displaying the **200-case resolution v3** result set.

## Images to publish

Place these exact PNG files in the repository's `docs/images/` folder:

- `streamlit-resolution-v3-overview.png` — v3 Snowflake Streamlit title, 200/200 metrics, outcomes chart, confusion matrix
- `streamlit-resolution-v3-case-explorer.png` — full case explorer, transcript and single-case drill-down

Use the original screen captures, not an AI-generated visual. The first screenshot is the cover image; the second documents the audit / exploration experience.

## Embed below “Streamlit in Snowflake dashboard” in README.md

```markdown
### Live Snowflake dashboard · 200 synthetic cases

![Actual Snowflake Streamlit dashboard for the 200-case Cortex resolution experiment](docs/images/streamlit-resolution-v3-overview.png)

*Figure 1. Live Streamlit in Snowflake, with Cortex AI_CLASSIFY outputs stored in Snowflake. The 200/200 result is exact agreement on constructed synthetic templates, not production accuracy.*

![Case-level prediction explorer running in Streamlit in Snowflake](docs/images/streamlit-resolution-v3-case-explorer.png)

*Figure 2. Live Snowsight case-level review: reference labels, Cortex predictions, customer transcript and stored inference result.*
```

## Suggested repository social preview

Use the overview screenshot or a 1280 × 640 composition with the Snowflake architecture diagram and clear “Synthetic Demo” descriptor. In GitHub: **Settings → General → Social preview**. Only use images you have rights to publish; do not imply Snowflake sponsorship.

## Accuracy of the claims

- All 200 utterances were produced from 20 templates × 10 product contexts.
- Observed exact reference-label agreement was 200/200, with 200 returned predictions.
- These screenshots show a **live** app, but a screenshot is not an independent performance validation.
- The first 8-case Streamlit screenshot is a **different app** and should not be substituted for v3.
