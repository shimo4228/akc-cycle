# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] — 2026-09-01

The rules file forks into two deliberate editions. This repo now owns the **self-contained edition** (no skills assumed); the author's harness runs a separate **pointer edition** that delegates each mechanism to installed skills. Previously the two files had drifted into being byte-identical — the compressed harness edition was being synced here, so the promised self-contained floor existed nowhere.

### Changed

- `rules/common/akc-cycle.md` — rewritten in English as the self-contained edition, owned by this repository (no longer synced from the harness): the six-phase Phase/Principle/Trigger table now lives in the rule body itself; Scaffold Dissolution gains its evidence standard (held-out transfer as completion evidence, active deletion of negative-delta artifacts — AKC ADR-0022 / ADR-0023); adds digests of three AKC worldview mechanisms — expiry-conditioned knowledge (ADR-0026), the judge/build/human attention topology (ADR-0024), and LLM-first artifact readability (ADR-0025).
- `scripts/sync-from-local.sh` — the rule is removed from the sync allowlist (payload is now 9 skills + 2 agents); the managed subtrees shrink to `skills/` and `agents/`.
- `README.md` / `llms.txt` / `llms-full.txt` — document the two-edition split and link the pointer edition running in the author's harness ([claude-harness](https://github.com/shimo4228/claude-harness/blob/main/rules/common/akc-cycle.md)) as the reference shape the rules file can shrink into once the plugin's skills are installed.

## [1.1.0] — 2026-07-15

The repository now doubles as a Claude Code plugin: rules-file copy-install (minimal floor) and plugin install (skill layer) live side by side as the cycle's two install paths.

### Added

- `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` — the repository is its own plugin marketplace (`/plugin marketplace add shimo4228/akc-cycle`); the single listed plugin sources from the repository root.
- `skills/` — the nine cycle-phase skills, synced from the harness canonical: search-first (Research), learn-eval (Extract), skill-stocktake / skill-health / rules-stocktake (Curate), rules-distill (Promote), skill-comply (Measure), context-sync / repo-asset-stocktake (Maintain).
- `agents/` — the two subagents the skills invoke: adr-writer, codemap-writer.

### Changed

- `scripts/sync-from-local.sh` — extended from the single-rule variant to a fixed-allowlist variant (1 rule + 9 skills + 2 agents) with staging, runtime-artifact pruning, YAML frontmatter validation, and directory-wide secret scan; still aborts on any missing component or origin marker, still never commits.
- `README.md` / `llms.txt` / `llms-full.txt` — restructured around the two install paths. Claude Code plugins cannot ship always-loaded rules, so the rules file remains copy-install only and is deliberately not part of the plugin payload.

## [1.0.0] — 2026-06-30

Initial release as a standalone rules-file repository.

### Added

- `rules/common/akc-cycle.md` — the Agent Knowledge Cycle distilled into a single behavioral rules file: six phases (Research, Extract, Curate, Promote, Measure, Maintain) plus Scaffold Dissolution, each with an explicit trigger condition. Installs the whole cycle without the six individual AKC skills.
- `scripts/sync-from-local.sh` — one-way export from the live Claude Code harness; the harness copy (`~/.claude/rules/common/akc-cycle.md`) is canonical, this repository is the publication mirror.

### Notes

- Previously published inside the [Agent Knowledge Cycle](https://github.com/shimo4228/agent-knowledge-cycle) repository as `docs/akc-cycle.md`. Extracted here as the cycle's rules-file install target so it has a single source of truth; the AKC repository now points to this repository instead of carrying a divergent copy. The judgment lineage (ADRs) and concept graph stay in the research repository.
