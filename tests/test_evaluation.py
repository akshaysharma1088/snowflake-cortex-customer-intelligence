import pytest

from customer_intelligence.evaluation import (
    categorize_sentiment_response,
    metrics,
    normalize_sentiment,
)


def test_normalize_sentiment():
    assert normalize_sentiment(" Negative ") == "negative"
    assert normalize_sentiment("surprised") == "unknown"
    assert normalize_sentiment(None) == "unknown"

def test_metrics():
    result = metrics(["negative", "positive", "negative"],
                     ["negative", "negative", "positive"])
    assert result["confusion"] == {"tp": 1, "fp": 1, "fn": 1, "tn": 0}
    assert result["f1"] == pytest.approx(.5)

def test_mismatch_and_empty():
    with pytest.raises(ValueError):
        metrics(["negative"], [])
    with pytest.raises(ValueError):
        metrics([], [])

def test_categorize():
    assert categorize_sentiment_response('{"categories":[{"name":"overall","sentiment":"negative"}]}') == "negative"
    assert categorize_sentiment_response("oops") == "unknown"
    assert categorize_sentiment_response({"categories": []}) == "unknown"
