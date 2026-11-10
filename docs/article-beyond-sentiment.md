# Beyond Sentiment: Building Resolution-Aware Customer Intelligence with Snowflake Cortex

*Draft for a Snowflake Community / technical engineering audience. Independent demonstration using synthetic conversations; no Snowflake or employer endorsement.*

A customer can say “thanks” and still be locked out of their account. A support ticket can be marked “resolved” while the underlying problem remains. Neither scenario is adequately represented by a positive/negative sentiment score.

This distinction inspired a small open-source demonstration: a Snowflake-native pipeline that enriches support transcripts and separately classifies evidence about issue resolution. The goal is not to replace support staff with a sentiment model. It is to give analysts a more useful evidence vocabulary: **confirmed resolved, reported unresolved, disputed, or unknown**.

## Architecture: separate generation from presentation

The prototype loads only synthetic support messages into Snowflake. A bounded SQL enrichment batch invokes `AI_SENTIMENT`, `AI_EXTRACT`, and `AI_CLASSIFY`, storing raw `VARIANT` outputs alongside a run version. Read-only views expose data to a Streamlit in Snowflake dashboard. Keeping inference off the dashboard refresh path avoids repeat model calls whenever someone changes a filter.

The initial eight-conversation smoke test confirmed the end-to-end pathway: eight sentiment outputs, eight entity extraction outputs, and eight issue classifications. Exact agreement against constructed sentiment and issue reference labels was 6/8 and 5/8, respectively. These tiny descriptive figures are useful for debugging, not for model evaluation.

One illuminating example was: “Thanks for the update. I appreciate your efforts, but my account is still locked.” The sentiment system returned **neutral**. That is not necessarily an incorrect polarity judgment; it simply doesn't answer whether the issue is still active. This motivated a distinct resolution-evidence classification task.

## Four states instead of one polarity score

For the resolution experiment, the categories were defined as:

| Resolution-evidence label | Operational meaning |
|---|---|
| `confirmed_resolved` | Customer explicitly verifies a fix or the desired outcome |
| `reported_unresolved` | Customer reports that a problem continues, without explicitly challenging a prior completion claim |
| `disputed` | Customer directly contradicts an earlier claim that the issue was fixed, completed, or resolved |
| `unknown` | There is not enough reliable evidence either way—for example, a procedural request or a promised future investigation |

These are **resolution-evidence labels**, not dissatisfaction labels. Neither “thank you” nor a promise from an agent proves a fix was successful. The distinction between `reported_unresolved` and `disputed` is especially meaningful for support quality control: a dispute implies a contradiction of some prior assertion of completion.

## What the experiments actually showed

A first version used 24 synthetic utterances. Cortex returned 24 predictions, of which **20 matched their authored references (83.33%)**. The errors were specific: three ongoing-issue messages were interpreted as `disputed`, and one future-oriented “please let me know when a fix is available” message was interpreted as `reported_unresolved`.

We then revised the instructions to make dispute criteria stricter and built a larger, versioned exercise of 200 synthetic messages. The 200-case sample was balanced: 50 examples each for confirmed resolved, reported unresolved, disputed, and unknown. Cortex returned predictions for all 200, and all 200 matched their authored labels.

That sounds definitive. It isn't.

The 200 messages consist of **20 authored sentence patterns instantiated across 10 support-product contexts**. They are simple, highly correlated examples that explicitly indicate their intended resolution state. This is a useful controlled demonstration that the requested taxonomy can be applied consistently, not evidence of 100% accuracy on real customer conversations. The prompt and the test set both changed between experiments, so we also **cannot claim the revised instructions alone raised accuracy from 83.33% to 100%**.

The most informative result is the *earlier failure mode*, not the perfect final number: a system may confuse an unsuccessful attempted fix with a disputed prior claim of successful resolution. This is precisely the type of semantic boundary worth documenting and testing.

## Building for reproducibility

The [public reference implementation](https://github.com/akshaysharma1088/snowflake-cortex-customer-intelligence) includes the SQL pipeline, synthetic inputs, Streamlit source, versioned experiment code, evaluation notes, and **case-level observed outputs**. You can inspect the complete 200-row export without a Snowflake account. Re-running inference requires compatible Snowflake Cortex privileges and incurs usage charges.

The design keeps raw model responses rather than immediately reducing them to a single dashboard metric. That matters when AI functions change their response schemas, classifications are questioned, or a support analyst wants to inspect the evidence behind a prediction. For production, additional safeguards would be necessary: appropriate transcript permissions, PII protection, role-based access, spending controls, retention policies, and human review for consequential escalation decisions.

## The practical lesson

Sentiment, expressed dissatisfaction, and issue resolution are related but different questions. A neutral utterance can describe an unresolved incident. A courteous closing does not establish success. A dispute is different from an ongoing issue without an explicit completion claim.

This project illustrates how to model those distinctions using Snowflake-native SQL and Streamlit, while making the limits of synthetic benchmarking visible. The next step for rigorous research would be a separately annotated, diverse and multi-turn evaluation set—not more copies of the same sentence templates.

**Explore the implementation:** https://github.com/akshaysharma1088/snowflake-cortex-customer-intelligence

*Reproducibility note: the results described here were observed in a November 2026 Snowflake trial run and supplied by the project author. They have not been independently replicated in a second account. No real customer or employer conversations were used.*
