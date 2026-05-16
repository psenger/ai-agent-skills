#!/usr/bin/env python3
"""Summarize trigger eval results and update EVAL-REPORT.md.

Usage: summarize_eval.py <results.json> <eval-report.md>

Reads a results.json produced by create-a-skill's run_loop, prints a
terminal summary, and rewrites the "Trigger eval results" block in
EVAL-REPORT.md with the latest numbers.
"""

import json
import re
import sys
from datetime import date


def main() -> None:
    if len(sys.argv) != 3:
        print("usage: summarize_eval.py <results.json> <eval-report.md>", file=sys.stderr)
        sys.exit(2)

    results_path, report_path = sys.argv[1], sys.argv[2]

    with open(results_path) as f:
        data = json.load(f)

    iteration = data["history"][0]
    results = iteration["train_results"]

    pos = [r for r in results if r["should_trigger"]]
    neg = [r for r in results if not r["should_trigger"]]
    tp = sum(r["triggers"] for r in pos)
    pos_runs = sum(r["runs"] for r in pos)
    fp = sum(r["triggers"] for r in neg)
    neg_runs = sum(r["runs"] for r in neg)
    tn = neg_runs - fp
    fn = pos_runs - tp
    precision = tp / (tp + fp) if (tp + fp) > 0 else 1.0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    accuracy = (tp + tn) / (tp + tn + fp + fn)

    print(f" Score:     {iteration['train_passed']}/{iteration['train_total']}")
    print(f" Precision: {precision:.0%}  (of triggers, how many were correct)")
    print(f" Recall:    {recall:.0%}  (of positives, how many fired)")
    print(f" Accuracy:  {accuracy:.0%}")
    print()
    print(" SHOULD TRIGGER:")
    for r in pos:
        mark = "PASS" if r["pass"] else "FAIL"
        print(f"  [{mark}] {r['triggers']}/{r['runs']}  {r['query'][:72]}")
    print()
    print(" SHOULD NOT TRIGGER:")
    for r in neg:
        mark = "PASS" if r["pass"] else "FAIL"
        print(f"  [{mark}] {r['triggers']}/{r['runs']}  {r['query'][:72]}")
    print()
    print(f" Results saved to: {results_path}")

    fn_list = [r for r in pos if not r["pass"]]
    fp_list = [r for r in neg if not r["pass"]]

    lines = [f"**Run {date.today()} — isolated, no competing skills**", ""]
    lines += [f"- **Score:** {iteration['train_passed']} / {iteration['train_total']}"]
    lines += [f"- **Precision:** {precision:.0%}"]
    lines += [f"- **Recall:** {recall:.0%}"]
    lines += [f"- **Accuracy:** {accuracy:.0%}"]

    if fn_list:
        lines += ["- **False negatives (should-trigger, did not fire):**"]
        for r in fn_list:
            lines += [f"  - {r['query']}"]
    else:
        lines += ["- **False negatives:** none"]

    if fp_list:
        lines += ["- **False positives (should not trigger, fired anyway):**"]
        for r in fp_list:
            lines += [f"  - {r['query']}"]
    else:
        lines += ["- **False positives:** none"]

    lines += ["- **Decision:** _update after review_"]
    block = "\n".join(lines)

    with open(report_path) as f:
        report = f.read()
    pattern = r"(### Trigger eval results\n)(.*?)(\n## Functional evals)"
    replacement = r"\1\n" + block + r"\n\3"
    updated = re.sub(pattern, replacement, report, flags=re.DOTALL)
    with open(report_path, "w") as f:
        f.write(updated)
    print(" EVAL-REPORT.md updated.")


if __name__ == "__main__":
    main()
