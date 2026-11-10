"""Pure Python evaluation utilities: no Snowflake account required."""
import json

ALLOWED_SENTIMENTS = {"positive", "negative", "neutral", "mixed", "unknown"}
def normalize_sentiment(value):
    if not isinstance(value, str):
        return "unknown"
    value = value.strip().lower()
    return value if value in ALLOWED_SENTIMENTS else "unknown"
def metrics(gold, predicted, positive_label="negative"):
    """Binary precision/recall/F1 for selected sentiment class."""
    if len(gold) != len(predicted):
        raise ValueError("gold and predicted lengths must match")
    if not gold:
        raise ValueError("evaluation data cannot be empty")
    pairs = [(normalize_sentiment(a), normalize_sentiment(b))
             for a, b in zip(gold, predicted)]
    tp = sum(a == positive_label and b == positive_label for a, b in pairs)
    fp = sum(a != positive_label and b == positive_label for a, b in pairs)
    fn = sum(a == positive_label and b != positive_label for a, b in pairs)
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    return {"sample_count": len(pairs), "precision": precision,
            "recall": recall, "f1": f1,
            "coverage": sum(b != "unknown" for _, b in pairs) / len(pairs),
            "confusion": {"tp": tp, "fp": fp, "fn": fn,
                          "tn": sum(a != positive_label and b != positive_label
                                    for a, b in pairs)}}
def categorize_sentiment_response(response):
    """Parse overall label; unknown when the schema differs from expectations."""
    if isinstance(response, str):
        try:
            response = json.loads(response)
        except (ValueError, TypeError):
            return "unknown"
    if not isinstance(response, dict):
        return "unknown"
    categories = response.get("categories", [])
    if not isinstance(categories, list):
        return "unknown"
    overall = next((item for item in categories if
                    isinstance(item, dict) and item.get("name") == "overall"), None)
    return normalize_sentiment(overall.get("sentiment") if overall else None)
