# Evaluation protocol

The included 90 conversations are **synthetic**, with illustrative gold labels. They are not independent annotations of real customer interactions.

Evaluate separately:
- Sentiment classification: macro-F1 and abstention/coverage, especially mixed sentiment and polite closings
- Issue classification: per-category precision and recall
- Named-entity extraction: exact and relaxed span/value matching, with explicit unknown cases
- Unresolved issue detection: error rates on partial and confirmed resolutions
- Operational costs: per-record inference consumption, retries, failures and elapsed time

## Reproducible run
1. Record account region, role, function availability, test date and input data hash.
2. Run a capped enrichment batch and inspect actual Cortex JSON response shapes.
3. Normalize predictions only after inspection.
4. Compare against gold labels with `customer_intelligence.evaluation.metrics`.
5. Report sampling bias, failure cases and counts alongside numbers.
6. Do not publish fabricated accuracy claims, cost figures or adoption claims.

The offline Python unit tests verify the evaluation logic, **not** Snowflake model performance.
