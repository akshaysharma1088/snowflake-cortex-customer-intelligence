# BIRD-inspired experimental extension

This module adds an **illustrative behavioral keyword baseline**, motivated by Akshay Sharma's independent manuscript, *Beyond Sentiment Polarity: Evaluating Behavior-Informed Customer Dissatisfaction Signals in Technical-Support Dialogues* (IET Software submission, under review).

**Important:** This is **not** the trained 20-feature BIRD-lite model, nor the unimplemented full BIRD or BIRD-Route framework. The 90 synthetic demo conversations are **not** the paper's 90 ABCD/MultiDoGO dialogue prefixes; the datasets must not be conflated. No Snowflake Cortex comparison results have been measured for this extension.

## Separate concepts

- **Polarity:** positive/neutral/negative/mixed tone (Snowflake Cortex sentiment is processed separately).
- **Expressed dissatisfaction:** `yes`, `no_evidence`, or `indeterminate` (the simple baseline emits only the first two).
- **Resolution:** `confirmed_resolved`, `reported_unresolved`, `disputed`, `unknown`.
- **Courtesy:** politeness, independent of dissatisfaction.
- **Evidence:** real supporting turn IDs require structured turns; this baseline does not provide evidence attribution.

## Offline quick start

```bash
python -m pip install -e ".[dev]"
python -m pytest -q
python -c "from customer_intelligence.behavioral import assess; print(assess('Thanks, but the fix still does not work.'))"
```

## Experimental roadmap

1. Convert each dialogue into `(speaker, turn_id, text)` records and use only preceding turns plus the target customer turn at inference time (causal masking).
2. Obtain independently labeled, consent-safe holdout examples. Do not redistribute copyrighted ABCD/MultiDoGO dialogue without checking applicable licenses.
3. Run Cortex on the **same fixed examples** as permitted BIRD-lite baseline code; retain raw model output, function version or model identifier where available, query IDs, region, timing and cost evidence.
4. Evaluate macro-F1, positive-class recall, support, abstentions and error slices. Include an issue-keyword rule and a sampling-stratum negative control, where the design permits.
5. Add dashboard confusion matrices and evidence tracing only after verified predictions are collected.
6. Require independent annotation and unbiased evaluation before making generalization or deployment claims.

The manuscript explicitly reports a small pilot with single-rater labels and cue-enriched sampling. Retain these limitations in public communications.
