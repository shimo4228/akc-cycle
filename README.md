# akc-cycle

A single **behavioral rules file** that installs the whole [Agent Knowledge Cycle (AKC)](https://github.com/shimo4228/agent-knowledge-cycle) — six phases (Research, Extract, Curate, Promote, Measure, Maintain) plus Scaffold Dissolution — into an AI agent's rules directory. It distills the cycle into actionable principles an agent can follow through natural conversation, **without installing the six individual AKC skills**.

This is the lightweight install path for AKC: one rule file, loaded every session, versus six probabilistically-triggered skill repositories.

## Install

### Claude Code

```bash
# Copy into your global rules directory
cp rules/common/akc-cycle.md ~/.claude/rules/common/akc-cycle.md
```

Any agent harness that loads a rules directory each session works the same way — point the copy at wherever your harness reads rules from.

## What it gives you

Each phase is a behavioral principle with an explicit **trigger** condition:

| Phase | Principle | Trigger |
|-------|-----------|---------|
| **Research** | Search broadly, filter by signal — define the signal before the search | A task that adds a dependency or creates a utility that might already exist |
| **Extract** | Capture reusable patterns from sessions | End of a productive session, after a hard-won debugging victory |
| **Curate** | Audit accumulated knowledge for redundancy, staleness, silence | When skills/rules grow noticeably, or a reference breaks |
| **Promote** | Elevate recurring patterns to rules | The same advice keeps resurfacing across skills and conversation |
| **Measure** | Verify behavioral change quantitatively | After adding or modifying a rule |
| **Maintain** | Keep documentation roles clean | After major refactoring, when context files bloat |

It closes with **Scaffold Dissolution**: these rules are scaffolding, and success is measured not by rule count but by whether the cycle runs naturally once internalized — by absorption inward (into conversation patterns) or downward (into the harness substrate).

## Syncing from the harness

The canonical copy of this rule lives in the author's live Claude Code harness (`~/.claude/rules/common/akc-cycle.md`). This repository is a one-way publication mirror:

```bash
scripts/sync-from-local.sh --dry-run   # report differences only
scripts/sync-from-local.sh             # apply to working tree (never commits)
```

## About this rule

This rules file belongs to the [Agent Knowledge Cycle (AKC)](https://github.com/shimo4228/agent-knowledge-cycle) research line — a Zenodo-citable six-phase bidirectional growth loop ([DOI 10.5281/zenodo.19200726](https://doi.org/10.5281/zenodo.19200726)) for sustaining intent alignment between an AI agent and its operator over time. The AKC repository holds the judgment lineage (ADRs), the concept-level knowledge graph, and the six standalone cycle skills; this repository is the cycle's **rules-file install target**. AKC is one of three research lines by [@shimo4228](https://github.com/shimo4228), alongside [Contemplative Agent](https://github.com/shimo4228/contemplative-agent) ([DOI 10.5281/zenodo.19212118](https://doi.org/10.5281/zenodo.19212118)) — autonomous agents grounded in four contemplative axioms — and [Agent Attribution Practice (AAP)](https://github.com/shimo4228/agent-attribution-practice) ([DOI 10.5281/zenodo.19652013](https://doi.org/10.5281/zenodo.19652013)) — harness-neutral ADRs on accountability distribution.

## License

MIT
