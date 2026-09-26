# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.1] — 2026-09-26

Fixes from the Claude directory validation report, and the payload is now English throughout.

### Added

- `.claude-plugin/icon.svg` — the plugin icon (directory check: no icon): a layered cut-paper spiral of six warm paper layers, one per cycle phase. 512×512, a JPEG embedded in an SVG wrapper so the paper texture survives.

### Changed

- `skills/` — the Japanese prose in the skills is translated into English: every SKILL.md (descriptions and trigger phrases included), adr-writer's `references/review-findings.md`, the pyproject comments, script docstrings and comments, and skill-comply's progress output. Japanese that scripts match against stays: regexes, test fixtures, and generation-audit's `runtime 照合: 編集 N 件` commit marker, which a harness ADR counts verbatim. The same edits are applied to the harness canonical, so later syncs keep them.
- `skills/` — every `uv run` in skill instructions now passes `--frozen`, so it resolves from the committed `uv.lock`. context-sync's suggested graph-lint command pins `pyld==3.3.0` (directory check: unpinned launcher).
- `scripts/sync-from-local.sh` — the sync now rewrites the published skills' own `~/.claude/skills/<name>` paths in Markdown to `${CLAUDE_PLUGIN_ROOT}/skills/<name>`, so bundled scripts resolve when the skills are installed as a plugin. Other `~/.claude` paths, such as the user's own library that the audit skills read, stay as written.
- `.claude-plugin/plugin.json` — version `1.4.1`.

## [1.4.0] — 2026-09-26

The plugin grows from nine to seventeen skills, ahead of the Claude directory submission: the Curate skill the AKC phase table already listed, plus the harness skills AKC v2.8.0 and its follow-up placement grounded on AKC concepts.

### Added

- `skills/agent-stocktake` — Curate: the audit for `~/.claude/agents/`, third sibling of skill-stocktake and rules-stocktake (already in AKC's phase table; missing from the payload until now).
- `skills/generation-audit` — re-audits rules and skills when a new model generation takes a role (AKC ADR-0023). rules-stocktake and skill-stocktake already named it as their evidence source.
- `skills/adr-writer` — expiry-conditioned knowledge (AKC ADR-0026). context-sync already delegated ADR extraction to it.
- `skills/harness-boundary` — Scaffold Dissolution at design time.
- `skills/review-to-lint` — code-LLM layering (AKC ADR-0008): machine-decidable reviewer items move to a deterministic script.
- `skills/llm-as-judge`, `skills/jev-judgment-design` — the judge pattern (AKC ADR-0008).
- `skills/author-calibrated-eval` — intent alignment: the author's blind reading decides what is worth reading.

### Changed

- `skills/` — the nine existing skills synced from the harness canonical (via the public [claude-harness](https://github.com/shimo4228/claude-harness) mirror, 2026-09-26): search-first adopts an established candidate that matches the need by default and closes with a per-need Adopt / Adopt-part / Build verdict; learn-eval cites the measurement by ADR instead of inlining it; context-sync, rules-stocktake, skill-comply, and skill-stocktake carry their current upstream text.
- `scripts/sync-from-local.sh` — the allowlist grows to 17 skills.
- `.claude-plugin/plugin.json` — version `1.4.0`; description names the companion skills. `.claude-plugin/marketplace.json` description updated to match.
- `README.md` / `llms.txt` / `llms-full.txt` — describe the payload as ten cycle-phase skills plus seven companions.

## [1.3.0] — 2026-09-19

The plugin payload shrinks to the nine cycle-phase skills. Both bundled subagents were retired in the author's harness, and the skills that used to call them now do that work in the main loop — no skill in the payload invokes a subagent that is no longer shipped.

### Removed

- `agents/adr-writer.md` — the `adr-writer` skill's main loop now writes the ADR body from a settled decision packet (harness ADR-0072). `context-sync` still delegates ADR extraction to the `adr-writer` skill, which is not part of this plugin.
- `agents/codemap-writer.md` — retired upstream (harness ADR-0062); `context-sync` no longer renders codemaps through it.
- `skills/learn-eval/knowledge-placement-decision.md` — folded into `skills/learn-eval/SKILL.md`.

### Changed

- `scripts/sync-from-local.sh` — the allowlist drops the `AGENTS` array and the managed subtrees shrink to `skills/` (9 skills). The previous allowlist aborted the sync because both agents no longer exist in the harness.
- `skills/` — synced from the harness canonical: search-first now returns a report instead of an Adopt / Extend / Compose / Build verdict; learn-eval routes every Save to a destination something reaches; context-sync, skill-comply, skill-health, skill-stocktake, rules-stocktake, rules-distill, and repo-asset-stocktake carry their current upstream text.
- `.claude-plugin/plugin.json` — version `1.3.0` (it had stayed at `1.1.0` through the 1.2.0 release, which did not touch the plugin payload); description no longer mentions subagents. `.claude-plugin/marketplace.json` description updated to match.
- `README.md` / `llms.txt` / `llms-full.txt` — describe the payload as nine skills.

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
