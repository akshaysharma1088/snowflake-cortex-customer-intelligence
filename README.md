# ❄️ Snowflake Cortex Customer Intelligence

An open-source reference implementation that turns **synthetic support conversations** into governed customer intelligence using Snowflake Cortex and Streamlit.

**Status:** Reference implementation; live Snowflake Cortex inference and dashboard deployment are not yet verified. Not endorsed by Snowflake or Salesforce. No Salesforce or real customer data included.

## Capabilities
- 90 synthetic support conversations with illustrative sentiment, issue and resolution labels
- Snowflake SQL DDL, staged CSV ingestion, Cortex enrichment and read-only analytics views
- `AI_SENTIMENT`, `AI_EXTRACT`, and `AI_CLASSIFY` in a bounded manual batch
- Streamlit dashboard to explore issue trends, transcripts and audit-friendly raw AI outputs
- Offline Python evaluation utilities, unit tests, CI and documentation

## Quick start
**Local tests (no Snowflake account required):**
```bash
python -m pip install -e ".[dev]"
python -m pytest -q
```

**Snowflake demonstration (warehouse and inference charges may apply):**
1. Run `sql/00_setup.sql` using an authorized setup role.
2. Stage `data/conversations.csv` using SnowSQL or Snowflake CLI:
```sql
USE DATABASE CORTEX_CI_DEMO;
USE SCHEMA APP;
PUT file://./data/conversations.csv @%CONVERSATIONS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
```
3. Run `sql/01_load.sql`; check `sql/04_validation.sql`.
4. Review Cortex permissions and inference costs; run `sql/02_enrich.sql` (capped at 25 records).
5. Run `sql/03_views.sql`, then deploy `streamlit_app.py` as Streamlit in Snowflake, with dependency and warehouse settings configured for your account.

Snowsight worksheets generally cannot upload local files using PUT; use an appropriate CLI or the Snowsight file loading interface. Cortex function access depends on account privileges, region and current function availability.

## Repository map
- `data/`: synthetic evaluation dataset
- `sql/`: setup, ingestion, enrichment, analytical views and validation
- `src/customer_intelligence/`: offline evaluation routines
- `tests/`: unit tests
- `docs/`: architecture, evaluation, security, publication roadmap
- `streamlit_app.py`: dashboard
- `snowflake.yml`: optional Snowflake CLI deployment manifest
- `.github/workflows/ci.yml`: tests and lint

## Responsible use
Do not point this demo at private support transcripts without company approval, PII handling, security review and a retention policy. AI sentiment does not establish actual customer satisfaction, and polite closings can hide unresolved problems. The synthetic labels are illustrative, not measured model accuracy.

See [architecture](docs/architecture.md), [evaluation](docs/evaluation.md), [security](docs/security.md), and [publishing plan](docs/publishing-plan.md).

## Official references
- [AI_SENTIMENT](https://docs.snowflake.com/en/sql-reference/functions/ai_sentiment)
- [AI_EXTRACT](https://docs.snowflake.com/en/sql-reference/functions/ai_extract)
- [AI_CLASSIFY](https://docs.snowflake.com/en/sql-reference/functions/ai_classify)

MIT licensed.

## BIRD-inspired behavior-aware extension

The new [BIRD research extension](docs/bird-extension.md) provides a transparent, **illustrative keyword baseline** separating courtesy, dissatisfaction and resolution evidence. It is **not** the trained BIRD-lite model described in the independently submitted manuscript. The synthetic 90-row demo dataset differs from the 90 public-corpus dialogue prefixes in that study, and there are no measured Cortex-vs-BIRD results yet. See `src/customer_intelligence/behavioral.py` and `tests/test_behavioral.py`.

### Comparing predictions after actual execution

After obtaining independently reviewed reference labels and **actual** Cortex inference outputs, create a CSV with columns `case_id,gold_dissatisfaction,rule_prediction,cortex_prediction` and run:

```bash
python -m pip install -e ".[dev]"
python scripts/compare_predictions.py your_predictions.csv
```

The comparison runner reports evaluated counts, coverage and binary precision/recall/F1; a blank Cortex prediction represents an abstention/unavailable result. **Cortex sentiment polarity is not the same variable as expressed dissatisfaction**—do not fill `cortex_prediction` by automatically treating positive sentiment as `no_evidence`. First define and document a separate dissatisfaction classifier or mapping and validate it. There are no precomputed Cortex benchmark results in this repository.
