# Snowflake Cortex smoke-test snapshot — November 2026

This file preserves **observed results reported by the project owner** from a Snowflake trial account, using eight deliberately authored synthetic support conversations (`SMOKE-001`–`SMOKE-008`). Results are stored in [`data/cortex_smoke_observed.csv`](../data/cortex_smoke_observed.csv). The model output was supplied as a pasted Snowflake result table; this record was not independently rerun or authenticated against the original Snowflake account. The raw nested VARIANT outputs were also supplied in the conversation but are not included in this compact CSV. Retain a separate raw Snowflake export for auditing.

## Descriptive outcomes (N=8)

- Sentiment: **6/8 exact label matches** (75%). Both mismatches are synthetic `mixed` examples for which Cortex produced `negative` or `neutral`; the observed overall labels show no `mixed` prediction.
- Issue category: **5/8 exact matches** (62.5%). Mismatches: `SMOKE-003` performance→other; `SMOKE-004` integration→performance; `SMOKE-005` other→billing.
- Resolution extraction: `yes` for `SMOKE-003` and `SMOKE-007`, `no` for all other cases. **Do not interpret** `no` as `reported_unresolved`: `SMOKE-005` and `SMOKE-008` contain procedural requests with no verified unresolved problem.
- The polite unresolved `SMOKE-006` received `neutral` sentiment while the text explicitly states the account is still locked. This is a polarity-versus-issue-evidence discrepancy, **not proof that a dissatisfaction classifier failed**.
- `SMOKE-004` extracted `ERR-502` and `webhook`; `SMOKE-003` extracted `dashboard` as both a product and feature, even though no product name is explicitly stated in its transcript.

## Interpretation constraints

These examples were authored with intentionally obvious cues and gold labels, so the percentages are **smoke-test descriptive match rates, not estimates of general performance or a peer-reviewed benchmark**. Source product metadata is not present inside every transcript, so extracted-product completeness cannot be judged from the external `PRODUCT` column alone. The `GOLD_UNRESOLVED=FALSE` field means a synthetic unresolved flag was absent; it does **not** imply confirmed resolution.

## Next experimental improvements

1. Expand to a **separate, independently annotated** evaluation sample with natural variation and counterexamples to cue rules.
2. Change resolution extraction to a four-class `confirmed_resolved | reported_unresolved | disputed | unknown` scheme; evaluate separately from polarity.
3. Run new inference under a versioned configuration and record function output schemas, time, region, query IDs and cost.
4. Export the original raw outputs from Snowflake before the trial expires. Do not publish personally identifying account information, tokens or credentials.
5. Compare AI sentiment only against polarity labels. For dissatisfaction comparisons, run a dedicated classifier/prompt with explicit operational labels.

**Provenance:** User-supplied Snowflake result table, November 2026. No employer or real-customer data.
