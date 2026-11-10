# ❄️ Snowflake Cortex Customer Intelligence

An open-source reference implementation that turns **synthetic support conversations** into governed customer intelligence using Snowflake Cortex and Streamlit.

**Status (November 2026):** Live Snowflake trial execution and Streamlit dashboard operation were confirmed by the project owner using 8 smoke-test conversations, followed by 24-case and 200-case synthetic resolution experiments. Complete observed exports are archived below. Results have not been independently reproduced in another account. This independent educational project is not endorsed by Snowflake or Salesforce and contains no real customer data.

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

The comparison runner reports evaluated counts, coverage and binary precision/recall/F1; a blank Cortex prediction represents an abstention/unavailable result. **Cortex sentiment polarity is not the same variable as expressed dissatisfaction**—do not fill `cortex_prediction` by automatically treating positive sentiment as `no_evidence`. First define and document a separate dissatisfaction classifier or mapping and validate it. The v2/v3 experiments below evaluate **resolution evidence**, not dissatisfaction.

## Run a Snowflake smoke test without installing a CLI

The shortest path is the new [Snowsight deployment guide](docs/deployment-validation.md). After `sql/00_setup.sql`, execute `sql/01_quickstart_seed.sql` to insert **8 synthetic scenarios** without any file upload, then `sql/00_preflight.sql` to verify AI function access and response shapes. With permissions and cost approval, run `sql/02_enrich.sql`, `sql/03_views.sql` and `sql/06_runtime_checks.sql`. Finally create Streamlit in Snowsight using `streamlit_app.py`. These steps were successfully exercised in a Snowflake trial account by the project owner in November 2026. Schema permissions, availability, and charges may differ in another account.

**Current validation status:** Python evaluation tests passed locally (remote GitHub CI not independently verified). The project owner supplied live Snowflake Cortex outputs from an 8-case smoke test and two versioned resolution experiments, and shared a running Streamlit screenshot. AI calls incur inference charges.

## Actual Snowflake trial results (November 2026)

The project owner ran the following experiments and supplied the resulting Snowflake exports:

| Experiment | Task | Exact reference-label matches | What it establishes |
|---|---|---:|---|
| [8-case smoke test](docs/observed-smoke-results.md) | Sentiment + issue type | Sentiment **6/8**, issue **5/8** | Pipeline and data-path functionality; several instructive mismatches |
| [Resolution v2, 24 cases](docs/resolution-v2-observed-results.md) | Four-class resolution evidence | **20/24 (83.33%)** | Errors distinguishing ongoing issues from disputed resolutions |
| [Resolution v3, 200 cases](docs/resolution-v3-observed-results.md) | Four-class resolution evidence | **200/200 (100%)** | Successful classification on deliberately simple template-driven synthetic examples |

**Source artifacts:** [8-case observations](data/cortex_smoke_observed.csv) · [24-case observed predictions](data/resolution_v2_observed.csv) · [200-case complete observed predictions](data/resolution_v3_observed.csv) · [v3 one-file SQL](sql/09_resolution_v3_200_benchmark.sql) · [publication draft](docs/article-beyond-sentiment.md).

**Important:** The 200 v3 examples are generated using **20 authored sentence patterns across 10 product contexts**, with **50 examples per class**. They are not 200 independently sampled customer conversations. Prompts and examples changed between v2 and v3, so their percentages cannot isolate a prompt improvement. Synthetic reference labels are not independent human annotations. These metrics are not estimates of real-world performance, and they do not measure the BIRD dissatisfaction classifier from the separate research manuscript.

## Offline access after a Snowflake trial ends

The source SQL, sampled synthetic data, and actual observed prediction files remain accessible in this repository. To repeat inference, you'll need a Snowflake account with Cortex access and appropriate costs/roles; to **inspect existing results**, no Snowflake account is required. Review the [reproducibility and results guide](docs/reproducibility-and-results.md) before citing benchmark numbers.

## How to contribute

Issues and pull requests that improve category definitions, create more naturally diverse labeled evaluation cases, check portability across Snowflake accounts, or improve privacy safeguards are welcome. Please label synthetic vs real data clearly and never post private customer transcripts or credentials.
