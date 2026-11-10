# Resolution v3.0: observed trial summary — November 9, 2026

**Source:** Results reported by the project owner from the Snowflake trial account using `sql/09_resolution_v3_200_benchmark.sql`. This summary was not independently verified through a Snowflake connector; the full per-case export remains to be archived.

## Overall results
| Metric | User-reported result |
|---|---:|
| Cases | 200 |
| Predictions returned | 200 |
| Exact matches against constructed reference labels | 200 |
| Coverage | 100.00% |
| Exact agreement | 100.00% |

## Observed confusion matrix (reference rows, predicted columns)
| Reference | confirmed_resolved | disputed | reported_unresolved | unknown |
|---|---:|---:|---:|---:|
| confirmed_resolved | 50 | 0 | 0 | 0 |
| disputed | 0 | 50 | 0 | 0 |
| reported_unresolved | 0 | 0 | 50 | 0 |
| unknown | 0 | 0 | 0 | 50 |

Macro-precision, macro-recall, and macro-F1 are each 1.000 *on this synthetic sample*.

## Critical limits
The benchmark was constructed from 20 distinct sentence templates (five per class) instantiated across 10 product/feature domains, producing 50 examples per class. Results are highly correlated across product substitutions, so 200 cases do **not** amount to 200 independent conversational examples. The class label is often directly indicated by phrasing.

V2: 20/24 (83.33%) on a different set of constructed examples; V3: 200/200 with revised classification instructions and different examples. The difference must **not** be described as a measured gain from prompt tuning because prompt and sample changed together and prompt design was informed by v2 errors.

This is **not** evidence of 100% natural-language understanding, real-world precision, or research superiority. The reference labels were assigned as part of generation rather than independently annotated, and the task is resolution evidence, not dissatisfaction or sentiment.

## Practical next steps before trial expiry
1. Download the full `SELECT * FROM V_RESOLUTION_V3_COMPARISON ORDER BY CASE_ID` result to CSV, retaining `RESOLUTION_RAW`, `RUN_AT`, and other provenance.
2. Archive the query IDs / query history and available inference cost or credit usage metadata.
3. Build a disjoint, natural-language-style challenge set with contrastive minimal pairs, ambiguous agent promises, partial resolutions, polite ongoing complaints, negation and multi-turn snippets, and preregister labels before running Cortex.
4. Include both v2 and v3 honestly in the project report and avoid extrapolating the observed rates.

**No employer or real-customer data used.**
