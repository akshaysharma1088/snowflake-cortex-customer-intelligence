"""Compare *measured* predictions after a real Snowflake run.

CSV columns: case_id, gold_dissatisfaction, rule_prediction, cortex_prediction.
No metrics are fabricated. Missing Cortex predictions are reported as coverage.
"""
import argparse
import csv
import json
from pathlib import Path

from customer_intelligence.behavioral import score_binary

VALID = {"yes", "no_evidence"}


def analyze(path):
    with Path(path).open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        raise ValueError("CSV is empty")
    required = {"case_id", "gold_dissatisfaction", "rule_prediction",
                "cortex_prediction"}
    if not required.issubset(rows[0]):
        raise ValueError("Missing required CSV columns: " +
                         ", ".join(sorted(required - set(rows[0]))))
    case_ids = [r["case_id"] for r in rows]
    if len(set(case_ids)) != len(case_ids):
        raise ValueError("Case IDs must be unique")
    if any(r["gold_dissatisfaction"] not in VALID for r in rows):
        raise ValueError("Gold labels must be yes or no_evidence")
    result = {"n_total": len(rows), "results": {}}
    for column in ("rule_prediction", "cortex_prediction"):
        valid = [r for r in rows if r[column] in VALID]
        result["results"][column] = {
            "evaluated": len(valid),
            "coverage": len(valid) / len(rows),
            "metrics": score_binary(
                [r["gold_dissatisfaction"] for r in valid],
                [r[column] for r in valid],
            ) if valid else None,
        }
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("predictions_csv")
    args = parser.parse_args()
    print(json.dumps(analyze(args.predictions_csv), indent=2))


if __name__ == "__main__":
    main()
