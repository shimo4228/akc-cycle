# akc-cycle

akc-cycle keeps the rules and skills in a Claude Code setup from piling up and going stale. Ask Claude to "audit my skills" and it reviews each one, proposes a verdict such as keep, merge or retire with a reason, and changes nothing until you confirm.

That audit is one of six habits the agent learns: search before building, keep what a session taught, audit what has accumulated, turn advice that keeps coming back into a rule, check that a rule changed behaviour, and keep docs to one home per fact. The agent is also told to delete its own rules once a habit runs without them. akc-cycle is the installable form of the [Agent Knowledge Cycle (AKC)](https://github.com/shimo4228/agent-knowledge-cycle), the author's method for keeping an AI agent aligned with its operator over time. The author's other work is listed under [More from the author](#more-from-the-author).

Listed in the Claude plugin directory (as of 2026-10-08, v1.5.0).

## Install

There are two parts, and each works without the other. The **rules file** is one Markdown file of about 5 KB (as of v1.5.0) that Claude Code reads at the start of every session, so the agent applies the habits without being asked. The **plugin** adds a skill for each step, with the procedure written out; if you only want the audits, the plugin alone is enough. Claude Code plugins have no slot for a rules file that loads every session (as of 2026-10-08), so the rules file is installed separately.

### Rules file

```bash
mkdir -p ~/.claude/rules
curl -fsSL -o ~/.claude/rules/akc-cycle.md \
  https://raw.githubusercontent.com/shimo4228/akc-cycle/main/rules/common/akc-cycle.md
```

Claude Code loads every Markdown file under `~/.claude/rules/` in every project. In another agent harness, save the file wherever that harness reads its rules. [Read the file](rules/common/akc-cycle.md) before you install it; to remove it, delete it.

### Plugin

```
/plugin marketplace add shimo4228/akc-cycle
/plugin install akc-cycle@akc-cycle
```

Then ask in plain words, such as "audit my skills", or call a skill by name, such as `/akc-cycle:skill-stocktake`. `skill-stocktake` answers "audit my skills". Each reason has to stand on its own; two examples from the skill's instructions show the level of detail:

| Verdict | Reason |
|---|---|
| Merge | 42-line thin content; Step 4 of chatlog-to-article already covers this workflow. Integrate the 'article angle' tip there as a note. |
| Improve | 276 lines; 'Framework Comparison' (L80–140) duplicates ai-era-architecture-principles. Delete it to reach ~150 lines. |

It then goes through each verdict other than Keep, shows the evidence and asks `[y/n/skip]` before it changes anything.

What the plugin adds and runs:

- It adds skills only: no hooks, no MCP servers, no settings.
- Most skills keep their description in context so Claude can pick them from a plain request, about 8,500 characters in all (as of v1.5.0); the full instructions load only when a skill runs. `skill-health`, `agent-stocktake`, `rules-distill`, `generation-audit`, `harness-boundary`, `llm-as-judge` and `author-calibrated-eval` stay out of context and run only when you call them by name. To install only some skills, see [Single skills](#single-skills).
- Some skills, `skill-stocktake` among them, run bundled Python scripts with [`uv`](https://docs.astral.sh/uv/) and Python 3.11 or later.
- The audit skills propose a verdict for each file (such as keep, update, merge, retire or dissolve) and change a file only after you confirm that file.
- `context-sync` edits existing documentation files without asking and lists every edit at the end, so `git diff` shows what changed; it asks once before creating new files.
- `skill-comply` and `skill-stocktake` start separate `claude -p` sessions, which use your Claude usage. `skill-stocktake` also checks every URL your skills name, and `search-first` and the audit skills may search the web.

### Single skills

The plugin installs all its skills together. To pick only some, these skills also have their own repositories, synced one way from the same source as the plugin, so between syncs they can trail it: [`search-first`](https://github.com/shimo4228/search-first), [`learn-eval`](https://github.com/shimo4228/learn-eval), [`skill-stocktake`](https://github.com/shimo4228/skill-stocktake), [`skill-health`](https://github.com/shimo4228/skill-health), [`rules-stocktake`](https://github.com/shimo4228/rules-stocktake), [`agent-stocktake`](https://github.com/shimo4228/agent-stocktake), [`rules-distill`](https://github.com/shimo4228/rules-distill), [`skill-comply`](https://github.com/shimo4228/skill-comply), [`context-sync`](https://github.com/shimo4228/context-sync), [`repo-asset-stocktake`](https://github.com/shimo4228/repo-asset-stocktake), [`generation-audit`](https://github.com/shimo4228/generation-audit), [`llm-as-judge`](https://github.com/shimo4228/llm-as-judge). `skill-stocktake` and `skill-health` run each other's scripts, and `generation-audit` runs `skill-health`'s scanner, so install those together. To install one, clone its repository and copy its skill folder; this example installs the `skill-stocktake` and `skill-health` pair:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/shimo4228/skill-stocktake
git clone https://github.com/shimo4228/skill-health
cp -r skill-stocktake/skills/skill-stocktake skill-health/skills/skill-health ~/.claude/skills/
```

A skill installed this way is called by its plain name, such as `/skill-stocktake`. The other skills in the plugin have no repository of their own.

## What each phase does

The rules file describes each phase as a habit with a trigger:

| Phase | When it applies, and what the agent does |
|---|---|
| **Research** | Before adding a dependency or writing a utility that may already exist: searches outside the repo first and reports what it found. |
| **Extract** | After a productive session or a hard debugging fix: decides whether the lesson is worth keeping and where it should go. |
| **Curate** | When skills, rules or agents have grown, or a reference breaks: finds duplicates, stale entries and entries that never fire. |
| **Promote** | When the same advice keeps coming back: turns it into a standing rule, with the reason. |
| **Measure** | After adding or changing a rule: checks that the agent now behaves differently. |
| **Maintain** | After a large refactor, or when context files bloat: keeps one home per fact and pointers elsewhere. |

The rules file also says when to delete a rule: once the habit runs without it, or once the model does the job well unprompted.

The plugin's skills, by phase:

- **Research**
  - `search-first`: searches the web, package registries and primary sources before you decide, and reports what it found.
- **Extract**
  - `learn-eval`: judges whether a session's lesson is worth keeping and routes it into an existing skill, rule or doc, or into a new skill.
  - `skill-creator`: writes or revises a skill; a reviewer that has not seen your conversation checks the draft, and you sign off. It installs as `/akc-cycle:skill-creator`, next to any other skill-creator you have.
- **Curate**
  - `skill-stocktake`, `rules-stocktake`, `agent-stocktake`: audit your skills, always-loaded rules and agent definitions, with a verdict for each file.
  - `skill-health`: finds structural debt in the skill library, such as a skill that names a script or another skill that does not exist.
  - `generation-audit`: re-checks your rules and skills when a new Claude model takes over a role.
  - `harness-boundary`: reviews a rule, skill or hook, before you add it or once the setup has grown, by asking which layer it belongs in and whether the next model will make it unnecessary; it can answer keep, simplify or delete.
- **Promote**
  - `rules-distill`: finds principles that recur across skills and drafts them as always-loaded rules.
  - `review-to-lint`: moves the mechanical items of a review checklist into a script.
- **Measure**
  - `skill-comply`: runs scenarios and reports how often a skill or rule is actually followed.
  - `measurement-discipline`: checks a threshold, an experiment result or an observation period before you rely on it.
  - `llm-as-judge`: designs LLM judges that give one named verdict instead of a summed score.
  - `author-calibrated-eval`: tunes LLM-written prose against your own blind reading.
  - `jev-judgment-design`: for users of TypeSafe's Jev library, moves yes/no judgments an LLM used to make (is this source relevant, is it new) into Jev, with code deciding, and checks every run against sources that must pass.
- **Maintain**
  - `context-sync`: finds overlapping and stale project docs and moves each fact to one home.
  - `repo-asset-stocktake`: finds configs, workflows and docs that nothing uses anymore.
  - `adr-writer`: records a design decision together with the conditions for revisiting it.
  - `verify-bootstrap`: sets up a repo's format, lint, type, security and test gates behind one script, or audits whether existing gates have gone stale. In an existing repo it fixes the current violations before it makes the rules blocking.

## How to cite

Cite AKC by its concept DOI, [10.5281/zenodo.19200726](https://doi.org/10.5281/zenodo.19200726), which always resolves to the latest version. The [AKC repository](https://github.com/shimo4228/agent-knowledge-cycle#how-to-cite) gives the BibTeX for the current release.

## More from the author

- **[Agent Knowledge Cycle](https://github.com/shimo4228/agent-knowledge-cycle)**: the reasoning behind each phase, recorded as dated design decisions.
- **[claude-harness](https://github.com/shimo4228/claude-harness)**: the author's own Claude Code setup, where these skills are written and used before they are published here.
- **[harness-scope](https://github.com/shimo4228/harness-scope)**: a Claude Code Mod that turns your global skills, agents, rules and tools on or off per repo with named profiles.
- **[shimo4228](https://github.com/shimo4228/shimo4228)**: the author's hub, with AKC next to the other research lines and their DOIs.

## License

MIT

<details>
<summary>For tools and AI assistants</summary>

**Identity.** akc-cycle is the install target for the Agent Knowledge Cycle (AKC, [DOI 10.5281/zenodo.19200726](https://doi.org/10.5281/zenodo.19200726)): a rules file and a Claude Code plugin that let an agent and its operator run AKC's six phases (Research, Extract, Curate, Promote, Measure, Maintain) over the agent's own skills, rules and docs. It is MIT-licensed and maintained by one author (@shimo4228). The AKC repository holds the reasoning (ADRs) and the concept-level knowledge graph; this repository holds what you install.

**Why two parts.** The rules file is loaded deterministically every session and is the floor: the cycle runs through conversation with no skills installed. Skills are loaded only when Claude judges a description relevant, so they carry the detailed procedures but cannot guarantee the cycle is in view. Claude Code plugins have no slot for always-loaded rules (as of 2026-10-08; a plugin could inject text with a hook, and this one ships none), so the rules file is a copy-install and is not in the plugin payload.

**Scaffold Dissolution.** The rules are scaffolding: success is the cycle running without being invoked, not the number of rules. A rule is simplified or deleted when its principle has been absorbed into conversation (inward) or the model or harness now does it natively (downward). Completion evidence is held-out transfer: the behaviour reproduces in a fresh context that never saw the rule. Artifacts that now override a better default are deleted, and this is audited at each model-generation change. The rules file also carries digests of three AKC mechanisms: expiry-conditioned knowledge, where every stored decision carries the conditions for revisiting it (ADR-0026); the judge/build/human split, where one model session verifies and dispatches, another builds, and the human keeps direction and the merge decision (ADR-0024); and LLM-first artifact readability, where skills, rules and records are written for the next session's LLM and machine checks enforce the standard (ADR-0025). Every promotion that shapes agent behaviour passes a human approval gate (ADR-0005).

**Two editions of the rules file.** This repository owns the self-contained edition, which assumes no skills. The author's harness runs a separate pointer edition that hands each mechanism to an installed skill or rule ([claude-harness `rules/common/akc-cycle.md`](https://github.com/shimo4228/claude-harness/blob/main/rules/common/akc-cycle.md)); it is the shape the rules file can shrink to once the plugin is installed. The two files have differed deliberately since 2026-09-01.

**Plugin payload.** The skills are grouped by phase as in the visible list above, which matches the AKC phase table. AKC concepts some of them ground: `skill-creator`, where Extract and Promote hand a new skill, behind a fresh-context draft review and the human's sign-off (ADR-0005); `generation-audit`, re-audit on a model-generation change (ADR-0023); `harness-boundary`, Scaffold Dissolution at design time; `review-to-lint`, code-LLM layering, where code owns what is deterministic and an LLM owns meaning, so whatever a script can decide moves out of the LLM reviewer (ADR-0008); `llm-as-judge` and `jev-judgment-design`, the judge pattern of the same layering, where an LLM or Jev judges and code enforces (ADR-0008), with llm-as-judge's own design adding binary checks as evidence and one named verdict instead of a summed score; `author-calibrated-eval`, intent alignment, with the author's own blind reading as the ground truth for LLM-written prose; `measurement-discipline`, evidence discipline for measured claims, thresholds and observation windows; `adr-writer`, expiry-conditioned decisions (ADR-0026); `verify-bootstrap`, machine gates as the enforcer of LLM-first readability (ADR-0025). The repository is its own marketplace (`.claude-plugin/marketplace.json`, source `./`); the version lives in `.claude-plugin/plugin.json` and the history in [CHANGELOG.md](CHANGELOG.md).

**Sync model.** The canonical copies of the plugin skills live in the author's Claude Code harness (`~/.claude/`). This repository is a one-way mirror of them: `scripts/sync-from-local.sh` publishes a fixed allowlist, aborts if a listed skill is missing or lacks its `origin` marker, and never commits (`--dry-run` reports differences only). The rules file is not synced.

**Links.**

- [llms.txt](llms.txt) and [llms-full.txt](llms-full.txt): the machine-readable summary and the question-and-answer reference.
- [rules/common/akc-cycle.md](rules/common/akc-cycle.md): the rules file.
- [Agent Knowledge Cycle](https://github.com/shimo4228/agent-knowledge-cycle): ADRs, knowledge graph and citation metadata.
- Sibling research lines by the same author: [Contemplative Agent](https://github.com/shimo4228/contemplative-agent) ([DOI 10.5281/zenodo.19212118](https://doi.org/10.5281/zenodo.19212118)), autonomous agents grounded in four contemplative axioms; [Agent Attribution Practice](https://github.com/shimo4228/agent-attribution-practice) ([DOI 10.5281/zenodo.19652013](https://doi.org/10.5281/zenodo.19652013)), harness-neutral ADRs on accountability distribution.

</details>
