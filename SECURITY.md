# Security Policy

## Supported Versions

Only the latest release on `main` receives security fixes. Older versions are not patched.

| Version | Supported          |
| ------- | ------------------ |
| 2.x (latest) | :white_check_mark: |
| < 2.0   | :x:                |

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Use GitHub's private vulnerability reporting to submit a report confidentially:

**[Report a vulnerability](https://github.com/psenger/ai-agent-skills/security/advisories/new)**

Your report is visible only to the maintainer. Include as much detail as you can:
- Which skill or file is affected
- Steps to reproduce or demonstrate the issue
- Potential impact

## Response Timeline

| Milestone | Target |
| --------- | ------ |
| Acknowledgement | Within 5 business days |
| Triage and severity assessment | Within 10 business days |
| Fix or mitigation | Dependent on severity and complexity |

## Disclosure Process

1. You submit a private advisory — only the maintainer can see it.
2. The maintainer acknowledges receipt and assesses severity.
3. A fix is developed and tested privately.
4. A patched release is published to `main`.
5. The advisory is published (coordinated disclosure). You will be credited unless you prefer to remain anonymous.

## Scope

**In scope:**
- SKILL.md files shipped in this repository
- Skill scripts and reference files under `skills/`
- The `.claude-plugin/marketplace.json` manifest

**Out of scope:**
- Skills installed from this repo into your own environment — those run under your own Claude Code configuration and are your responsibility to audit.
- Third-party tools or services invoked by skills (Claude API, GitHub API, etc.).
- Vulnerabilities in Claude Code itself — report those to [Anthropic](https://www.anthropic.com/security).
