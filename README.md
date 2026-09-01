# akc-cycle

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/shimo4228/akc-cycle)

The install entry point for the [Agent Knowledge Cycle (AKC)](https://github.com/shimo4228/agent-knowledge-cycle) — six phases (Research, Extract, Curate, Promote, Measure, Maintain) plus Scaffold Dissolution. Two install paths, minimal to full:

1. **Rules file (minimal, recommended floor)** — a single self-contained behavioral rules file, loaded every session, that distills the cycle into actionable principles an agent can follow through natural conversation, without installing any skills. This edition is owned by this repository.
2. **Claude Code plugin (skill layer)** — the nine cycle-phase skills plus the two subagents they invoke, installed via the plugin marketplace.

## Install

### Path 1 — Rules file (minimal)

```bash
# Copy into your global rules directory
cp rules/common/akc-cycle.md ~/.claude/rules/common/akc-cycle.md
```

Any agent harness that loads a rules directory each session works the same way — point the copy at wherever your harness reads rules from. This path is harness-agnostic and is all you need for the cycle to run.

> **Two editions**: this repo ships the **self-contained edition** (no skills assumed). The author's live harness runs a separate **pointer edition** — same mechanisms, but each one delegated to an installed skill or resident rule — published in [claude-harness `rules/common/akc-cycle.md`](https://github.com/shimo4228/claude-harness/blob/main/rules/common/akc-cycle.md). If you install the plugin (Path 2), the pointer edition is the reference shape for what the rules file can shrink into.

### Path 2 — Claude Code plugin (skill layer)

```
/plugin marketplace add shimo4228/akc-cycle
/plugin install akc-cycle@akc-cycle
```

Installs nine skills bound to the six phases — `search-first` (Research), `learn-eval` (Extract), `skill-stocktake` / `skill-health` / `rules-stocktake` (Curate), `rules-distill` (Promote), `skill-comply` (Measure), `context-sync` / `repo-asset-stocktake` (Maintain) — plus the `adr-writer` and `codemap-writer` subagents they invoke.

> **Note**: Claude Code plugins cannot ship always-loaded rules, so the plugin does **not** include the rules file. The rules file (Path 1) is the cycle's floor; the plugin adds the deeper how-to layer on top. The skills are scaffolding by design — see Scaffold Dissolution below.

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

It closes with **Scaffold Dissolution**: these rules are scaffolding, and success is measured not by rule count but by whether the cycle runs naturally once internalized — by absorption inward (into conversation patterns) or downward (into the harness substrate). The rules file also carries the dissolution evidence standard (held-out transfer as completion evidence, active deletion of negative-delta artifacts) and digests of three AKC worldview mechanisms: expiry-conditioned knowledge (ADR-0026), the judge/build/human attention topology (ADR-0024), and LLM-first artifact readability (ADR-0025).

## Syncing from the harness

The canonical copies of the skill-layer components — the nine skills and the two subagents — live in the author's live Claude Code harness (`~/.claude/`). This repository is a one-way publication mirror for those; the sync script publishes a fixed allowlist and aborts if any listed component is missing or lacks its origin marker. The rules file is **not** synced: this repo owns the self-contained edition, while the harness runs the pointer edition (two deliberately different files since 2026-09-01):

```bash
scripts/sync-from-local.sh --dry-run   # report differences only
scripts/sync-from-local.sh             # apply to working tree (never commits)
```

## About this repository

This repository belongs to the [Agent Knowledge Cycle (AKC)](https://github.com/shimo4228/agent-knowledge-cycle) research line — a Zenodo-citable six-phase bidirectional growth loop ([DOI 10.5281/zenodo.19200726](https://doi.org/10.5281/zenodo.19200726)) for sustaining intent alignment between an AI agent and its operator over time. The AKC repository holds the judgment lineage (ADRs) and the concept-level knowledge graph; this repository is the cycle's **install target** — the rules file plus the skill-layer plugin. Each cycle skill also has its own standalone repository under [@shimo4228](https://github.com/shimo4228). AKC is one of three research lines by [@shimo4228](https://github.com/shimo4228), alongside [Contemplative Agent](https://github.com/shimo4228/contemplative-agent) ([DOI 10.5281/zenodo.19212118](https://doi.org/10.5281/zenodo.19212118)) — autonomous agents grounded in four contemplative axioms — and [Agent Attribution Practice (AAP)](https://github.com/shimo4228/agent-attribution-practice) ([DOI 10.5281/zenodo.19652013](https://doi.org/10.5281/zenodo.19652013)) — harness-neutral ADRs on accountability distribution.

## License

MIT
