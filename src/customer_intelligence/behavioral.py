"""Transparent illustrative rules; NOT a reproduction of trained BIRD-lite."""
import re

COURTESY = re.compile(r"\b(thank(?:s| you)?|appreciate|please)\b", re.IGNORECASE)
UNRESOLVED = re.compile(
    r"\b(still (?:not|cannot|can't|fails?|broken|does not work|doesn't work)"
    r"|not (?:resolved|working|fixed)|no fix|has not|have not"
    r"|keeps? fail(?:ing)?|cannot (?:sign in|access|log in)"
    r"|issue is still open|not appeared yet)\b", re.IGNORECASE
)
RESOLVED = re.compile(
    r"\b(?:now works?|working (?:well|now)|is resolved|issue (?:was|is) resolved"
    r"|can (?:sign|log) in now|was repaired|fixed it)\b", re.IGNORECASE
)
COMPLAINT = re.compile(
    r"\b(?:error|fail(?:s|ed|ing)?|duplicate charge|frustrat(?:ed|ing)"
    r"|terrible|not happy|disput(?:e|ed)|escalat(?:e|ion))\b", re.IGNORECASE
)


def assess(target_turn: str) -> dict:
    """Evaluate *only* the supplied target customer turn, not full dialogue.

    no_evidence does not mean satisfaction; unknown does not mean resolved.
    """
    if not isinstance(target_turn, str):
        raise TypeError("target_turn must be a string")
    courtesy = bool(COURTESY.search(target_turn))
    unresolved = bool(UNRESOLVED.search(target_turn))
    resolved = bool(RESOLVED.search(target_turn))
    complaint = bool(COMPLAINT.search(target_turn))
    resolution = (
        "disputed" if unresolved and resolved
        else "reported_unresolved" if unresolved
        else "confirmed_resolved" if resolved
        else "unknown"
    )
    return {
        "courtesy": courtesy,
        "dissatisfaction": "yes" if unresolved or complaint else "no_evidence",
        "resolution": resolution,
        "polite_unresolved_flag": courtesy and unresolved,
        "evidence_turn_ids": [],
        "method": "illustrative_keyword_baseline_v1",
    }


def score_binary(gold: list[str], predicted: list[str], positive="yes") -> dict:
    if len(gold) != len(predicted) or not gold:
        raise ValueError("gold and predictions must have equal nonzero lengths")
    tp = sum(g == positive and p == positive for g, p in zip(gold, predicted))
    fp = sum(g != positive and p == positive for g, p in zip(gold, predicted))
    fn = sum(g == positive and p != positive for g, p in zip(gold, predicted))
    tn = len(gold) - tp - fp - fn
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    return {"n": len(gold), "tp": tp, "fp": fp, "fn": fn, "tn": tn,
            "precision": precision, "recall": recall, "f1": f1}
