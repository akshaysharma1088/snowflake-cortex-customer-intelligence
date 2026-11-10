# Deployment validation: live Snowflake steps

This project has passed offline Python tests, but **no live Snowflake session is connected** and no successful Cortex execution is asserted.

## Route A: Snowsight-only smoke test (recommended)

1. In a test account, select a role with permission to create the demo database, schema and X-SMALL warehouse. Review object names and costs.
2. Run `sql/00_setup.sql`, then `sql/01_quickstart_seed.sql` (8 synthetic cases; no PUT or files needed).
3. Confirm that the operating role can query the demo tables and has the `SNOWFLAKE.CORTEX_USER` database role for AI functions (directly or via role inheritance). Check regional AI function availability and organizational policies.
4. Run `sql/00_preflight.sql`. This performs one call to each AI function and returns raw responses. Stop if a call errors.
5. Review the batch limit and version in `sql/02_enrich.sql`; run it once. The first run enriches up to 25 rows. It incurs AI function usage costs.
6. Run `sql/03_views.sql` and then `sql/06_runtime_checks.sql`. Record pass/fail observations, error messages, and query IDs.
7. Create a Streamlit app in Snowsight with `streamlit_app.py` and set its query warehouse to the demo warehouse. Test the dashboard under the intended restricted read-only role.
8. Only when verified, write a dated release note with region and test results (no tokens, passwords, or sensitive account details).

## Route B: Full dataset (90 synthetic cases)

Use SnowSQL or Snowflake CLI to upload `data/conversations.csv` and execute `sql/01_load.sql`. Do not combine the 8-row smoke sample and full dataset when computing model benchmark metrics; reset tables or filter cohorts explicitly.

## Important test assertions
- Both `CONVERSATIONS` and `ENRICHED_CONVERSATIONS` exist.
- `AI_SENTIMENT` returns an `overall` category in `categories`.
- `AI_EXTRACT` returns extracted fields in `response`.
- `AI_CLASSIFY` returns an array `labels`.
- Bounded enrichment creates successfully processed rows and retains raw variants.
- The Streamlit app loads data *without executing new inference*.
- Report real query costs and runtime only after measuring them.
- Do not equate polarity with dissatisfaction or infer verified issue resolution from polite tone.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Insufficient privileges | Active role, warehouse USAGE, object privileges, SNOWFLAKE.CORTEX_USER |
| Unsupported AI function | Region, cross-region inference policy, function availability |
| No rows in dashboard | Confirm seed/load, views, role SELECT grants |
| Streamlit doesn't start | Runtime-specific dependencies, compute pool if container runtime, query warehouse |
| Unexpected JSON shape | Inspect raw Cortex outputs in `sql/00_preflight.sql` |
| Duplicate records | Do not repeatedly COPY to the same table without deduplication |

## Caution
The 8 smoke cases deliberately have illustrative labels; they cannot establish measured accuracy. The main dataset is also synthetically labeled and is not the independent BIRD manuscript evaluation set.

References:
- https://docs.snowflake.com/en/sql-reference/functions/ai_sentiment
- https://docs.snowflake.com/en/sql-reference/functions/ai_extract
- https://docs.snowflake.com/en/sql-reference/functions/ai_classify
- https://docs.snowflake.com/en/developer-guide/streamlit/app-development/creating-your-app
