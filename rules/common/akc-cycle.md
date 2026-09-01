<!-- origin: shimo4228 -->
<!-- edition: self-contained — for harnesses WITHOUT the cycle-phase skills installed. This file is owned by this repo (not synced from the author's harness since 2026-09-01); the author's live harness runs a separate pointer edition that delegates each mechanism to installed skills. -->
# Agent Knowledge Cycle (self-contained edition)

A six-phase cycle for metabolizing an agent's experience into improvable knowledge,
distilled into one always-loaded rules file. It runs through natural conversation —
no skills required. Source of judgment lineage:
[agent-knowledge-cycle](https://github.com/shimo4228/agent-knowledge-cycle) (ADRs cited below).

## The six phases

Each phase is a behavioral principle with an explicit trigger. When a trigger fires,
apply the principle in conversation.

| Phase | Principle | Trigger |
|-------|-----------|---------|
| **Research** | Search broadly, filter by signal — define the signal before the search. Prefer existing solutions over building | A task adds a dependency or creates a utility that might already exist |
| **Extract** | Capture reusable patterns from sessions as candidate knowledge (a note, a draft skill, a rule sketch) | End of a productive session; after a hard-won debugging victory |
| **Curate** | Audit accumulated knowledge for redundancy, staleness, and silence (entries that never fire). Merge duplicates, date-stamp doubts | Skills/rules grow noticeably; a reference breaks |
| **Promote** | Elevate patterns that keep recurring into standing rules — with the *why*, not just the instruction | The same advice resurfaces across artifacts and conversation |
| **Measure** | Verify behavioral change, not artifact count — did the rule actually change what the agent does? | After adding or modifying a rule |
| **Maintain** | Keep documentation roles clean: one home per fact, pointers elsewhere | After major refactoring; when context files bloat |

Every promotion that shapes agent behavior passes a named **human approval gate**
(ADR-0005): the human owns direction and the merge switch.

## Scaffold Dissolution

These rules are scaffolding. Success is measured not by rule count but by whether
the cycle runs naturally once internalized. Simplify or delete a rule when practice
no longer needs it:

- **Inward** — the principle has been absorbed into conversation patterns
- **Downward** — the substrate (model or harness) now provides the capability
  natively, and the handwritten rule would override a better default

A model-generation turnover is a downward trigger: re-audit prohibitions,
exhaustive procedures, and repeated emphasis written for older, weaker models.

Evidence standard for dissolving (ADR-0022 / ADR-0023):

- **Completion evidence is held-out transfer** — behaving the same with the
  scaffold removed *in the same context* is only necessary evidence. Dissolve when
  the behavior reproduces in a fresh context that never saw the scaffold
- **The negative pole gets deleted, not shelved** — an artifact carrying negative
  information (a drifted rule overriding a now-better default) is actively removed.
  Silence, ablation, and transfer all detect only *absence*; audit for negative
  deltas explicitly at each model-generation turnover

## Expiry-conditioned knowledge (ADR-0026)

- A stored decision carries its own expiry conditions (review-when). A
  recommendation whose expiry conditions cannot be stated is freshness-unknown —
  weight it weakly
- Decisions are dated hypotheses. When a new idea conflicts with an old decision,
  supersede is the normal path — keep the record, overwrite the judgment, leave a
  dated note instead of deleting
- Rejection records follow the same reading: a past "don't re-propose" is a dated
  hypothesis, not a permanent veto. Use it when adopting, never to narrow the
  question space while diverging

## Three-role attention topology (ADR-0024)

Human attention is the scarce resource (ADR-0010). Under scarcity the loop splits
into **judge** (spends model judgment to save human judgment: premise verification,
worth-doing calls, dispatch, independent acceptance), **build** (implements), and
**human** (direction and the binary merge gate only). What moves upstream is
attention, not authority — the approval gate stays human.

## LLM-first artifact readability (ADR-0025)

The default reader, editor, and reviewer of cycle artifacts (skills, rules,
distilled knowledge, decision records) is the next session's LLM. Optimize for
locality over deep abstraction and explicitness over cleverness; the yardstick is
context economy. Preserve verifiability (types, tests, frozen goldens, stated
invariants) rather than prose explanations — those can be regenerated on demand.
Budget human-facing prose only for the README and output surface text.
