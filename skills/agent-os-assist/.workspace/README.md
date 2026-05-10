# Trigger Eval — agent-os-assist

How to run the trigger eval suite and read the results.

## Quick start

Run this from the repo root:

```bash
bash skills/agent-os-assist/.workspace/run-trigger-eval.sh
```

The script handles everything: isolating the environment, smoke-testing auth, running the eval, and restoring your original `~/.claude` when done.

## What the script does

1. Moves `~/.claude` to `~/.claude-back` (atomic rename).
2. Builds a minimal `~/.claude` containing only `sessions/`, `config/`, and `statsig/` — no competing skills.
3. Smoke-tests auth with `claude -p 'say: ok'`. Exits early if auth fails.
4. Runs one eval pass with no train/test holdout.
5. Prints a summary and updates `EVAL-REPORT.md` with the latest results.
6. Restores `~/.claude` from `~/.claude-back` — always, even on error or Ctrl-C.

**If the script crashes mid-run** and leaves `~/.claude-back` behind, check that `~/.claude` looks correct, then remove `~/.claude-back` manually before retrying.

## Reading the output

The terminal summary looks like this:

```
 Score:     13/13
 Precision: 100%  (of triggers, how many were correct)
 Recall:    80%   (of positives, how many fired)
 Accuracy:  92%

 SHOULD TRIGGER:
  [PASS] 3/3  How do I turn jira ticket into an Agent OS spec
  [FAIL] 1/3  I dont know what to do now that I installed agent-os
  ...

 SHOULD NOT TRIGGER:
  [PASS] 0/3  Set up a new Node.js project structure with Express and TypeScript
  ...

 Results saved to: .workspace/evals/results/2026-05-10_153012/results.json
```

- **Precision** — of all the times the skill triggered, what fraction was correct. False positives hurt this.
- **Recall** — of all the queries that should have triggered the skill, what fraction actually did. False negatives hurt this.
- **Accuracy** — overall correct rate across both positive and negative queries.

Raw results are saved as JSON under `.workspace/evals/results/<timestamp>/results.json`.

## Advanced: run the eval loop directly

For more control — more iterations, different models, holdout testing — call the underlying script directly. Run from the repo root:

```bash
PYTHONPATH="$HOME/.claude/skills/create-a-skill" python3 -m scripts.run_loop \
  --eval-set skills/agent-os-assist/.workspace/evals/trigger-evals.json \
  --skill-path skills/agent-os-assist \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --holdout 0.4 \
  --verbose
```

### Parameters

| Parameter | Default | Description |
|---|---|---|
| `--eval-set` | required | Path to the trigger eval JSON file. |
| `--skill-path` | required | Path to the skill directory (must contain `SKILL.md`). |
| `--model` | required | Claude model ID to use for running queries and generating description improvements. |
| `--max-iterations` | `5` | How many improve-and-retest cycles to run before stopping. Set to `1` for a diagnostic pass with no improvement. |
| `--holdout` | `0.4` | Fraction of the eval set to reserve as a held-out test set. The improvement loop only sees the training split. Set to `0` to use all queries for training (no test set). |
| `--runs-per-query` | `3` | How many times each query is run. The trigger rate across all runs determines pass/fail. Higher values reduce flakiness but take longer. |
| `--trigger-threshold` | `0.5` | Minimum trigger rate to count a query as "triggered". At `0.5` with 3 runs, 2 out of 3 must trigger. |
| `--num-workers` | `10` | Number of parallel `claude -p` processes. Reduce if you hit rate limits. |
| `--timeout` | `30` | Seconds to wait per query before marking it as not triggered. |
| `--description` | none | Override the description from `SKILL.md` with a specific string to test. Useful for A/B testing a candidate description without editing the file. |
| `--report` | `auto` | Where to write the HTML report. `auto` writes to a temp file and opens it in your browser. `none` disables the report. Any other value is treated as a file path. |
| `--results-dir` | none | Directory to save a timestamped run folder containing `results.json`, `report.html`, and improvement logs. |
| `--verbose` | off | Print per-query results and progress to stderr while running. |

### The improvement loop

When `--max-iterations` is greater than 1, the loop:

1. Runs all eval queries against the current description.
2. Identifies which queries failed.
3. Asks the model to propose an improved description.
4. Re-runs the eval with the new description.
5. Repeats until all train queries pass or max iterations is reached.

The best description (by test score if a holdout is set, otherwise by train score) is printed in the JSON output as `best_description`. To apply it, copy that value into the `description:` field in `SKILL.md`.

## Eval query file

The eval queries live at:

```
.workspace/evals/trigger-evals.json
```

Each entry has three fields:

```json
{
  "query": "the user prompt to test",
  "should_trigger": true,
  "notes": "why this query was included"
}
```

Edit this file to add, remove, or adjust queries. After editing, re-run the shell script to see the updated results.
