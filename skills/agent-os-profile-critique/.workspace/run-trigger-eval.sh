#!/usr/bin/env bash
# Isolated trigger eval for agent-os-profile-critique.
#
# Runs the eval in a sandboxed HOME so the user's real installation directory
# is never read, written, renamed, or copied. Auth flows through
# ANTHROPIC_API_KEY via `claude -p --bare` (see create-a-skill's
# --bare-claude engine flag).
set -euo pipefail

# ── Auth precheck ────────────────────────────────────────────────────────────
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo "ERROR: ANTHROPIC_API_KEY must be set."
    echo "       The runner uses 'claude -p --bare', which reads auth only"
    echo "       from that env var. Existing OAuth sessions are not used."
    exit 1
fi

# ── Paths (all repo-relative; no \$HOME references) ──────────────────────────
WORKSPACE_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$WORKSPACE_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
ENGINE_DIR="$REPO_ROOT/skills/create-a-skill"
EVAL_SET="$WORKSPACE_DIR/evals/trigger-evals.json"
RESULTS_DIR="$WORKSPACE_DIR/evals/results"

# ── Sandbox HOME so the eval cannot see installed user skills ────────────────
SANDBOX="$(mktemp -d)"
echo "==> Sandbox HOME: $SANDBOX"

cleanup() {
    python3 -c 'import shutil, sys; shutil.rmtree(sys.argv[1], ignore_errors=True)' "$SANDBOX"
}
trap cleanup EXIT

# ── Run the eval ─────────────────────────────────────────────────────────────
echo "==> Running trigger eval (1 iteration, no holdout, --bare auth) ..."
(
    cd "$ENGINE_DIR"
    HOME="$SANDBOX" python3 -m scripts.run_loop \
        --eval-set "$EVAL_SET" \
        --skill-path "$SKILL_DIR" \
        --model claude-sonnet-4-6 \
        --max-iterations 1 \
        --holdout 0 \
        --verbose \
        --report none \
        --results-dir "$RESULTS_DIR" \
        --bare-claude
) | tee /tmp/eval-results-latest.json

# ── Summarize and update EVAL-REPORT.md ──────────────────────────────────────
LATEST=$(ls -td "$RESULTS_DIR"/* 2>/dev/null | head -1 || true)
if [ -n "$LATEST" ] && [ -f "$LATEST/results.json" ]; then
    echo ""
    echo "========================================"
    echo " TRIGGER EVAL SUMMARY"
    echo "========================================"
    python3 "$WORKSPACE_DIR/summarize_eval.py" "$LATEST/results.json" "$WORKSPACE_DIR/EVAL-REPORT.md"
    echo "========================================"
fi
