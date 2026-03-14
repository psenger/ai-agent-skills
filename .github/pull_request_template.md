## What

<!-- Brief description of the change. -->

## Why

<!-- Why is this change needed? Link to an issue if one exists. -->

## Type of Change

- [ ] New skill
- [ ] Enhancement to existing skill
- [ ] Bug fix (skill not working as expected)
- [ ] Documentation
- [ ] Repo maintenance

## Skill Checklist

<!-- If this PR adds or modifies a skill, verify: -->

- [ ] `SKILL.md` has valid YAML frontmatter (`name`, `description`, `allowed-tools`)
- [ ] `name` is lowercase-hyphenated and matches the directory name
- [ ] `description` is written in third person with trigger words
- [ ] Reference files are in `references/` (one level deep)
- [ ] Examples are in `examples/` if applicable
- [ ] `SKILL.md` is under 500 lines
- [ ] No secrets, credentials, or PII committed
- [ ] `.claude-plugin/marketplace.json` updated (if new skill)
- [ ] `README.md` skills table updated (if new skill)

## Testing

- [ ] Tested locally by invoking the skill with a realistic prompt
- [ ] Verified the skill activates correctly (not confused with another skill)
