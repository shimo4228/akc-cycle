# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-06-30

Initial release as a standalone rules-file repository.

### Added

- `rules/common/akc-cycle.md` — the Agent Knowledge Cycle distilled into a single behavioral rules file: six phases (Research, Extract, Curate, Promote, Measure, Maintain) plus Scaffold Dissolution, each with an explicit trigger condition. Installs the whole cycle without the six individual AKC skills.
- `scripts/sync-from-local.sh` — one-way export from the live Claude Code harness; the harness copy (`~/.claude/rules/common/akc-cycle.md`) is canonical, this repository is the publication mirror.

### Notes

- Previously published inside the [Agent Knowledge Cycle](https://github.com/shimo4228/agent-knowledge-cycle) repository as `docs/akc-cycle.md`. Extracted here as the cycle's rules-file install target so it has a single source of truth; the AKC repository now points to this repository instead of carrying a divergent copy. The judgment lineage (ADRs) and concept graph stay in the research repository.
