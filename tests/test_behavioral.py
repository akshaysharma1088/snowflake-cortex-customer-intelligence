from customer_intelligence.behavioral import assess, score_binary


def test_polite_unresolved():
    r = assess("Thanks for checking, but the fix still does not work.")
    assert r["courtesy"] and r["polite_unresolved_flag"]
    assert r["resolution"] == "reported_unresolved"
    assert r["dissatisfaction"] == "yes"


def test_explicit_resolution():
    r = assess("Thanks! The issue is resolved and everything works now.")
    assert r["resolution"] == "confirmed_resolved"
    assert not r["polite_unresolved_flag"]


def test_no_evidence_not_satisfaction():
    r = assess("Please send the updated receipt.")
    assert r["dissatisfaction"] == "no_evidence"
    assert r["resolution"] == "unknown"


def test_binary_score():
    result = score_binary(
        ["yes", "yes", "no_evidence"],
        ["yes", "no_evidence", "yes"],
    )
    assert (result["tp"], result["fp"], result["fn"], result["tn"]) == (1, 1, 1, 0)
    assert result["f1"] == 0.5
