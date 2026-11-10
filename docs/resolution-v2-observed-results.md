# Resolution v2.0: observed trial results — 2026-11-09

**Status:** User-provided Snowflake result export from a trial account, not independently reproduced through a Snowflake connection. Source: [case-level CSV](../data/resolution_v2_observed.csv). All 24 cases are constructed synthetic utterances; they are **not** the BIRD paper's research corpus.

## Observed aggregate
- Predictions returned: **24 / 24 (100% coverage)**.
- Exact label agreement: **20 / 24 (83.33%)**.
- Descriptive macro-F1: **0.856**, macro precision **0.875**, macro recall **0.865**.
- All 6 reference disputed cases were predicted disputed, but 3 non-disputed cases were also predicted disputed.
- 5 of 8 reference reported-unresolved cases were predicted correctly (62.5% recall).

## Error analysis
| Case | Reference | Prediction | Key phrasing |
|---|---|---|---|
| R2-001 | reported_unresolved | disputed | "Thanks ... fix still does not work" |
| R2-002 | reported_unresolved | disputed | "I appreciate ... account remains locked" |
| R2-004 | reported_unresolved | disputed | "Thanks ... still crashing after patch" |
| R2-018 | unknown | reported_unresolved | "Please let me know when a fix is available" |

The three `reported_unresolved → disputed` errors share a polite or appreciative opening; however **this is not proof that courtesy caused the errors**, because the sample is designed, small, and confounded with other phrase differences (references to prior fixes and updates). In particular R2-001 and R2-004 refer to an attempted fix, which could reasonably invite a dispute interpretation without a stricter decision rule. R2-018 suggests that a future-oriented request can be misread as explicit ongoing failure.

## Confusion matrix (reference rows, model columns)
| Reference | confirmed_resolved | disputed | reported_unresolved | unknown |
|---|---:|---:|---:|---:|
| confirmed_resolved | 4 | 0 | 0 | 0 |
| disputed | 0 | 6 | 0 | 0 |
| reported_unresolved | 0 | 3 | 5 | 0 |
| unknown | 0 | 0 | 1 | 5 |

## Interpretation and limitations
This measures **agreement with researcher-authored synthetic reference labels**, not production accuracy. The 24 test examples and prompts were designed in the same development workflow; an improved prompt evaluated on these same cases is **development-set tuning**, not a held-out generalization test. Do not compare these figures directly with BIRD-lite's manuscript Macro-F1: different target concepts, datasets, and evaluation protocols.

## Suggested next study
- Version a stricter rule: `disputed` only when a prior actor explicitly **asserted completion/resolution** and the customer contradicts it; mere reports of failed fixes or continuing problems are `reported_unresolved`.
- Classify `unknown` when the statement requests future information without explicitly describing present failure.
- Evaluate new rules on a separate, precommitted set of disjoint examples; preserve v2.0 results unchanged.
- Record actual inference function, region, query IDs, and costs if available before account expiry.
