---
name: create-a-skill
license: Apache-2.0
description: >
  Create new agent skills from scratch, modify and improve existing skills, and measure skill
  performance through evaluation and benchmarking. Use when users want to create a skill, write a
  skill, build a new skill, edit or optimize an existing skill, run evals to test a skill, benchmark
  skill performance, or optimize a skill's description for better triggering accuracy. Also triggers
  when users say "turn this into a skill", "make a skill for X", "skill for doing Y", or ask about
  skill structure, skill format, or SKILL.md files.
---

# Create a Skill

A skill for creating new skills from scratch and iteratively improving them through testing, user feedback, and evaluation.

## Overview

The process of creating a skill follows this loop:

1. **Gather requirements** — interview the user, research the domain
2. **Write a draft** — create SKILL.md and any bundled resources
3. **Test** — run Claude-with-the-skill on realistic prompts
4. **Evaluate** — help the user review outputs qualitatively and quantitatively
5. **Improve** — rewrite based on feedback
6. **Repeat** until the user is satisfied
7. **Optimize description** — tune triggering accuracy
8. **Package** — create a distributable `.skill` file

Your job is to figure out where the user is in this process and jump in. Maybe they say "I want to make a skill for X" — help them from step 1. Maybe they already have a draft — go straight to testing. Always be flexible: if the user says "just vibe with me", skip the formal eval loop.

---

## Phase 1: Gather Requirements

### Capture Intent

Start by understanding what the user wants. The conversation might already contain a workflow they want to capture (e.g., "turn this into a skill"). If so, extract answers from the conversation history first — tools used, sequence of steps, corrections the user made, input/output formats observed.

Ask these questions (skip any already answered):

1. **What should this skill enable Claude to do?** — the core capability
2. **What task or domain does it cover?** — scope and boundaries
3. **What specific use cases should it handle?** — concrete scenarios
4. **When should this skill trigger?** — user phrases, contexts, keywords
5. **What's the expected output format?** — files, text, structured data
6. **Does it need executable scripts or just instructions?** — deterministic operations
7. **Any reference materials to include?** — docs, APIs, schemas
8. **Should we set up test cases?** — skills with objectively verifiable outputs (file transforms, data extraction, code generation) benefit from test cases; subjective skills (writing style, art) often don't. Suggest the appropriate default, but let the user decide.

### Interview and Research

Proactively ask about edge cases, input/output formats, example files, success criteria, and dependencies. Don't write test prompts until you've ironed this out.

**Research the domain.** If the skill involves specific technologies, frameworks, or APIs:
- Check available MCPs for searching docs or finding similar skills
- Use web search to look up best practices, official documentation, or reference implementations
- Research in parallel via subagents if available, otherwise inline
- Come prepared with context to reduce burden on the user

Wait for the user to confirm your understanding before proceeding to the draft.

---

## Phase 2: Write the Skill

### Skill Anatomy

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    — Executable code for deterministic/repetitive tasks
    ├── references/ — Docs loaded into context as needed
    └── assets/     — Files used in output (templates, icons, fonts)
```

### SKILL.md Frontmatter

Required fields:
- **name**: Kebab-case identifier, max 64 characters, no leading/trailing/consecutive hyphens
- **description**: What it does + when to trigger. Max 1024 characters. No angle brackets.

Optional fields:
- **compatibility**: Required tools/dependencies (max 500 characters)
- **license**: License identifier
- **allowed-tools**: Tools the skill needs
- **metadata**: Additional metadata

#### Writing a Good Description

The description is **the only thing Claude sees** when deciding which skill to load. It appears in the system prompt alongside all other installed skills.

**Format:**
- First sentence: what capability this skill provides
- Second sentence: "Use when [specific triggers]"
- Include specific keywords, contexts, and file types
- Write in third person
- Be slightly "pushy" — Claude tends to under-trigger skills, so include phrases like "Make sure to use this skill whenever..."

**Good example:**
```
Extract text and tables from PDF files, fill forms, merge documents. Use when working
with PDF files or when user mentions PDFs, forms, or document extraction. Make sure to
use this skill whenever the user mentions any PDF-related task, even if they don't
explicitly ask for extraction.
```

**Bad example:**
```
Helps with documents.
```

### Progressive Disclosure

Skills use a three-level loading system:
1. **Metadata** (name + description) — Always in context (~100 words)
2. **SKILL.md body** — In context whenever skill triggers (<500 lines ideal)
3. **Bundled resources** — Loaded as needed (unlimited; scripts can execute without loading)

**Key patterns:**
- Keep SKILL.md under 500 lines; if approaching this, add hierarchy with clear pointers
- Split into separate reference files when SKILL.md exceeds 100 lines, content has distinct domains, or advanced features are rarely needed
- Reference files clearly from SKILL.md with guidance on when to read them
- For large reference files (>300 lines), include a table of contents

**Domain organization** — when a skill supports multiple domains/frameworks:
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude reads only the relevant reference file.

### When to Add Scripts

Add utility scripts when:
- Operation is deterministic (validation, formatting, data transforms)
- Same code would be generated repeatedly across invocations
- Errors need explicit handling
- A computation is cheaper to run than to reason about

Scripts save tokens and improve reliability vs. generated code. If all your test runs independently write similar helper scripts, that's a strong signal to bundle the script.

### Writing Style

- Use the imperative form in instructions
- Explain the **why** behind everything you ask the model to do. Today's LLMs are smart — they have good theory of mind and when given good reasoning can go beyond rote instructions. If you find yourself writing ALWAYS or NEVER in all caps, reframe and explain the reasoning instead.
- Use theory of mind; make the skill general, not super-narrow to specific examples
- Write a draft, then look at it with fresh eyes and improve it

**Defining output formats:**
```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

**Examples pattern:**
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### Principle of Lack of Surprise

Skills must not contain malware, exploit code, or content that could compromise system security. A skill's contents should not surprise the user in their intent if described. Don't create misleading skills or skills designed to facilitate unauthorized access or data exfiltration. Roleplay skills are OK.

### Review Checklist

After drafting, verify:
- [ ] Description includes triggers ("Use when...")
- [ ] SKILL.md under 500 lines (100 if simple)
- [ ] No time-sensitive info that will go stale
- [ ] Consistent terminology throughout
- [ ] Concrete examples included
- [ ] References are one level deep (no chains)
- [ ] Scripts bundled for any deterministic/repetitive operations

Present the draft to the user and ask:
- Does this cover your use cases?
- Anything missing or unclear?
- Should any section be more or less detailed?

---

## Phase 3: Test and Evaluate

After writing the skill, create 2–3 realistic test prompts — the kind of thing a real user would actually say. Share them: "Here are a few test cases I'd like to try. Do these look right, or do you want to add more?"

Save test cases to `evals/evals.json` (don't write assertions yet — just prompts):

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

See `references/schemas.md` for the full schema including the `expectations` field (added later).

### Running Test Cases

This is one continuous sequence — don't stop partway through.

Put results in `<skill-name>-workspace/` as a sibling to the skill directory. Organize by iteration (`iteration-1/`, `iteration-2/`, etc.) and each test case gets a directory (`eval-0/`, `eval-1/`, etc.). Create directories as you go.

#### Step 1: Spawn all runs in the same turn

For each test case, spawn two subagents in the same turn — one with the skill, one without (baseline). Launch everything at once.

**With-skill run:**
```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
```

**Baseline run** (depends on context):
- **New skill**: no skill at all. Save to `without_skill/outputs/`.
- **Improving existing skill**: the old version. Snapshot first (`cp -r`), then point baseline at snapshot. Save to `old_skill/outputs/`.

Write an `eval_metadata.json` for each test case with a descriptive name:
```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

#### Step 2: Draft assertions while runs are in progress

Draft quantitative assertions and explain them to the user. Good assertions are objectively verifiable and have descriptive names. Subjective skills (writing style, design quality) are better evaluated qualitatively.

Update `eval_metadata.json` and `evals/evals.json` with the assertions.

#### Step 3: Capture timing data as runs complete

When each subagent completes, save `total_tokens` and `duration_ms` to `timing.json`:
```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

This data comes through the task notification and isn't persisted elsewhere — capture it immediately.

#### Step 4: Grade, aggregate, and launch the viewer

Once all runs are done:

1. **Grade each run** — use `agents/grader.md` instructions. Save to `grading.json`. The expectations array must use fields `text`, `passed`, and `evidence`. For programmatically checkable assertions, write and run a script.

2. **Aggregate into benchmark:**
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```

3. **Analyst pass** — read benchmark data and surface patterns. See `agents/analyzer.md` ("Analyzing Benchmark Results" section).

4. **Launch the viewer:**
   ```bash
   nohup python <skill-creator-path>/eval-viewer/generate_review.py \
     <workspace>/iteration-N \
     --skill-name "my-skill" \
     --benchmark <workspace>/iteration-N/benchmark.json \
     > /dev/null 2>&1 &
   VIEWER_PID=$!
   ```
   For iteration 2+, also pass `--previous-workspace <workspace>/iteration-<N-1>`.

   **Headless environments:** Use `--static <output_path>` to write standalone HTML.

5. **Tell the user** the results are ready for review.

#### Step 5: Read the feedback

When the user is done, read `feedback.json`. Empty feedback means it was fine. Focus improvements on test cases with specific complaints.

Kill the viewer: `kill $VIEWER_PID 2>/dev/null`

---

## Phase 4: Improve the Skill

This is the heart of the loop.

### How to Think About Improvements

1. **Generalize from the feedback.** You're iterating on a few examples to move fast, but the skill will be used across many different prompts. Don't overfit — avoid fiddly changes or oppressively constrictive MUSTs. If something is stubborn, try different metaphors or recommend different patterns.

2. **Keep the prompt lean.** Remove things that aren't pulling their weight. Read the transcripts, not just final outputs — if the skill makes the model waste time on unproductive steps, trim those instructions.

3. **Explain the why.** Transmit your understanding of the task and the user's intent into the instructions. Use reasoning over rigid structures.

4. **Look for repeated work.** If all test runs independently wrote similar helper scripts or took the same multi-step approach, bundle that script in `scripts/`.

### The Iteration Loop

1. Apply improvements to the skill
2. Rerun all test cases into a new `iteration-<N+1>/` directory with baseline runs
3. Launch the viewer with `--previous-workspace`
4. Wait for user review
5. Read feedback, improve, repeat

Keep going until:
- The user says they're happy
- Feedback is all empty
- You're not making meaningful progress

---

## Phase 5: Description Optimization

After the skill is done, offer to optimize the description for better triggering accuracy.

### Step 1: Generate trigger eval queries

Create 20 eval queries — mix of should-trigger and should-not-trigger:

```json
[
  {"query": "the user prompt", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false}
]
```

Queries must be realistic — concrete, specific, with file paths, personal context, column names, URLs. Some casual with typos, some formal. Focus on edge cases.

**Should-trigger (8–10):** Different phrasings of the same intent, cases where the user doesn't name the skill explicitly but clearly needs it, uncommon use cases, competitive cases.

**Should-not-trigger (8–10):** Near-misses that share keywords but need something different. Avoid obviously irrelevant queries — the negative cases should be genuinely tricky.

### Step 2: Review with user

Present using the HTML template from `assets/eval_review.html`:
1. Read the template
2. Replace `__EVAL_DATA_PLACEHOLDER__`, `__SKILL_NAME_PLACEHOLDER__`, `__SKILL_DESCRIPTION_PLACEHOLDER__`
3. Write to temp file and open it
4. User edits, then exports — check `~/Downloads/eval_set.json`

### Step 3: Run the optimization loop

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id-powering-this-session> \
  --max-iterations 5 \
  --verbose
```

This handles the full loop: 60/40 train/test split, 3x runs per query, iterative improvement.

### Step 4: Apply the result

Update SKILL.md frontmatter with `best_description`. Show before/after and report scores.

---

## Phase 6: Package

### Validate

```bash
python -m scripts.quick_validate <path/to/skill-folder>
```

### Package

```bash
python -m scripts.package_skill <path/to/skill-folder>
```

If `present_files` tool is available, present the `.skill` file to the user. Otherwise, tell them the file path.

---

## Advanced: Blind Comparison

For rigorous comparison between two skill versions, read `agents/comparator.md` and `agents/analyzer.md`. Two outputs are given to an independent agent without telling it which is which, then analyzed for why the winner won. This is optional and most users won't need it.

---

## Communicating with the User

People across a wide range of coding familiarity use this. Pay attention to context cues:
- "evaluation" and "benchmark" are borderline, but OK
- For "JSON" and "assertion", look for cues the user knows these terms before using them unexplained
- Briefly explain terms when in doubt

---

## Environment-Specific Adaptations

### Claude.ai (no subagents)

- Run test cases one at a time yourself (less rigorous but useful sanity check)
- Skip baseline runs
- Present results inline instead of via browser viewer
- Skip quantitative benchmarking
- Skip description optimization (requires `claude` CLI)
- Skip blind comparison
- Packaging works if Python + filesystem available

### Cowork (headless)

- Subagents work; use them for parallel test runs
- Use `--static <output_path>` for the viewer (no browser)
- Feedback via downloaded `feedback.json`
- Description optimization works (uses `claude -p`)
- ALWAYS generate the eval viewer before evaluating inputs yourself

### Updating an Existing Skill

- Preserve the original name and `name` frontmatter field
- Copy to a writable location before editing (installed path may be read-only)
- If packaging manually, stage in `/tmp/` first

---

## Reference Files

Read these when you need them:

- `agents/grader.md` — How to evaluate assertions against outputs
- `agents/comparator.md` — How to do blind A/B comparison
- `agents/analyzer.md` — How to analyze why one version beat another
- `references/schemas.md` — JSON structures for evals.json, grading.json, benchmark.json, etc.

---

## Core Loop (Summary)

1. Figure out what the skill is about — interview the user, research the domain
2. Draft or edit the skill
3. Run Claude-with-the-skill on test prompts
4. Evaluate outputs with the user:
   - Create benchmark.json and run `eval-viewer/generate_review.py`
   - Run quantitative evals
5. Improve and repeat until satisfied
6. Optimize the description
7. Package and deliver
