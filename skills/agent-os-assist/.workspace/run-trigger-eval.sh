#!/usr/bin/env bash
# Isolated trigger eval for agent-os-expert.
#
# 1. Moves ~/.claude to ~/.claude-back (atomic rename)
# 2. Builds a minimal ~/.claude with only auth files
# 3. Smoke-tests auth before wasting time on a broken run
# 4. Runs the trigger eval
# 5. Restores ~/.claude — always, even on error or ctrl-c
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude-back"
SCRIPT_DIR="$HOME/.claude-back/skills/create-a-skill"

WORKSPACE_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_EVAL_SET="$WORKSPACE_DIR/evals/trigger-evals.json"
SKILL_PATH="$(cd "$WORKSPACE_DIR/.." && pwd)"
RESULTS_DIR="$WORKSPACE_DIR/evals/results"

# ── restore ────────────────────────────────────────────────────────────────────

restore() {
    echo ""
    echo "==> Restoring ~/.claude ..."
    rm -rf "$CLAUDE_DIR"
    mv "$BACKUP_DIR" "$CLAUDE_DIR"
    echo "    Done."
}

trap restore EXIT

# ── guard: nothing left behind from a previous crashed run ────────────────────

if [ -d "$BACKUP_DIR" ]; then
    echo "ERROR: $BACKUP_DIR already exists — a previous run may not have restored cleanly."
    echo "       If ~/.claude looks correct, remove $BACKUP_DIR and retry."
    exit 1
fi

# ── move ~/.claude aside ──────────────────────────────────────────────────────

echo "==> Moving ~/.claude to ~/.claude-back ..."
mv "$CLAUDE_DIR" "$BACKUP_DIR"
echo "    Done."

# ── build minimal ~/.claude with auth only ────────────────────────────────────

echo ""
echo "==> Building minimal ~/.claude (auth only) ..."
mkdir -p "$CLAUDE_DIR"
for dir in sessions config statsig; do
    if [ -d "$BACKUP_DIR/$dir" ]; then
        cp -R "$BACKUP_DIR/$dir" "$CLAUDE_DIR/$dir"
        echo "  copied: $dir"
    else
        echo "  not found, skipping: $dir"
    fi
done

# ── smoke-test auth ───────────────────────────────────────────────────────────

echo ""
echo "==> Smoke-testing auth (claude -p 'say: ok') ..."
if ! claude -p "say: ok" --output-format text > /dev/null 2>&1; then
    echo "ERROR: auth check failed — claude -p could not authenticate."
    echo "       Check that sessions/, config/, or statsig/ contain valid credentials."
    exit 1
fi
echo "    Auth OK."

# ── run eval ──────────────────────────────────────────────────────────────────

echo ""
echo "==> Running trigger eval (1 iteration, no holdout) ..."
PYTHONPATH="$SCRIPT_DIR" python3 -m scripts.run_loop \
    --eval-set "$SKILL_EVAL_SET" \
    --skill-path "$SKILL_PATH" \
    --model claude-sonnet-4-6 \
    --max-iterations 1 \
    --holdout 0 \
    --verbose \
    --report none \
    --results-dir "$RESULTS_DIR" \
    | tee /tmp/eval-results-latest.json

# Print terminal summary and update EVAL-REPORT.md
LATEST=$(ls -td "$RESULTS_DIR"/* 2>/dev/null | head -1)
if [ -n "$LATEST" ] && [ -f "$LATEST/results.json" ]; then
    echo ""
    echo "========================================"
    echo " TRIGGER EVAL SUMMARY"
    echo "========================================"
    python3 - "$LATEST/results.json" "$WORKSPACE_DIR/EVAL-REPORT.md" <<'PYEOF'
import json, sys, re
from datetime import date

data = json.load(open(sys.argv[1]))
report_path = sys.argv[2]
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
recall    = tp / (tp + fn) if (tp + fn) > 0 else 0.0
accuracy  = (tp + tn) / (tp + tn + fp + fn)

# Terminal output
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
print(f" Results saved to: {sys.argv[1]}")

# Build markdown results block
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

lines += [f"- **Decision:** _update after review_"]
block = "\n".join(lines)

# Replace the results section in EVAL-REPORT.md
report = open(report_path).read()
pattern = r'(### Trigger eval results\n)(.*?)(\n## Functional evals)'
replacement = r'\1\n' + block + r'\n\3'
updated = re.sub(pattern, replacement, report, flags=re.DOTALL)
open(report_path, "w").write(updated)
print(f" EVAL-REPORT.md updated.")
PYEOF
    echo "========================================"
fi