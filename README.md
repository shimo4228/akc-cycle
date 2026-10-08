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
- Most skills keep their description in context so Claude can pick them from a plain request, about 8,500 characters in all (as of v1.5.0); the full instructions load only when a skill runs. `skill-health`, `agent-stocktake`, `rules-distill`, `generation-audit`, `harness-boundary`, `llm-as-judge` and `author-calibrated-eval` stay out of context and run only when you call them by name. The plugin installs all its skills together.
- Some skills, `skill-stocktake` among them, run bundled Python scripts with [`uv`](https://docs.astral.sh/uv/) and Python 3.11 or later.
- The audit skills propose a verdict for each file (such as keep, update, merge, retire or dissolve) and change a file only after you confirm that file.
- `context-sync` edits existing documentation files without asking and lists every edit at the end, so `git diff` shows what changed; it asks once before creating new files.
- `skill-comply` and `skill-stocktake` start separate `claude -p` sessions, which use your Claude usage. `skill-stocktake` also checks every URL your skills name, and `search-first` and the audit skills may search the web.

## What each phase does

The rules file describes each phase as a habit with a trigger. Under each phase name are the plugin's skills for it.

| Phase and skills | When it applies, and what the agent does |
|---|---|
| **Research**<br>`search-first` | Before adding a dependency or writing a utility that may already exist: searches outside the repo first and reports what it found. |
| **Extract**<br>`learn-eval` | After a productive session or a hard debugging fix: decides whether the lesson is worth keeping and where it should go. |
| **Curate**<br>`skill-stocktake`<br>`skill-health`<br>`rules-stocktake`<br>`agent-stocktake` | When skills, rules or agents have grown, or a reference breaks: finds duplicates, stale entries and entries that never fire. |
| **Promote**<br>`rules-distill` | When the same advice keeps coming back: turns it into a standing rule, with the reason. |
| **Measure**<br>`skill-comply` | After adding or changing a rule: checks that the agent now behaves differently. |
| **Maintain**<br>`context-sync`<br>`repo-asset-stocktake` | After a large refactor, or when context files bloat: keeps one home per fact and pointers elsewhere. |

The rules file also says when to delete a rule: once the habit runs without it, or once the model does the job well unprompted.

The plugin also has companion skills. Each one puts an AKC idea to work outside the phase procedures above:

- `skill-creator`: writes or revises a skill; a reviewer that has not seen your conversation checks the draft, and you sign off. It installs as `/akc-cycle:skill-creator`, next to any other skill-creator you have.
- `generation-audit`: re-checks your rules and skills when a new Claude model takes over a role.
- `harness-boundary`: before you add a rule, skill or hook, asks which layer it belongs in and whether the next model will make it unnecessary.
- `adr-writer`: records a design decision together with the conditions for revisiting it.
- `review-to-lint`: moves the mechanical items of a review checklist into a script.
- `llm-as-judge`: designs LLM judges that give one named verdict instead of a summed score.
- `jev-judgment-design`: for users of TypeSafe's Jev library, moves yes/no judgments an LLM used to make (is this source relevant, is it new) into Jev, with code deciding.
- `author-calibrated-eval`: tunes LLM-written prose against your own blind reading.
- `verify-bootstrap`: sets up a repo's format, lint, type, security and test gates behind one script. In an existing repo it fixes the current violations before it makes the rules blocking.
- `measurement-discipline`: checks a threshold, an experiment result or an observation period before you rely on it.

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

**Plugin payload.** Phase skills: `search-first` (Research), `learn-eval` (Extract), `skill-stocktake`, `skill-health`, `rules-stocktake`, `agent-stocktake` (Curate), `rules-distill` (Promote), `skill-comply` (Measure), `context-sync`, `repo-asset-stocktake` (Maintain). Companion skills and the AKC concept each grounds: `skill-creator` (where Extract and Promote hand a new skill, behind a fresh-context draft review and the human's sign-off, ADR-0005), `generation-audit` (re-audit on a model-generation change, ADR-0023), `harness-boundary` (Scaffold Dissolution at design time), `adr-writer` (expiry-conditioned decisions, ADR-0026), `review-to-lint` (code-LLM layering: whatever a script can decide moves out of the LLM reviewer, ADR-0008), `llm-as-judge` and `jev-judgment-design` (the judge pattern: binary checks as evidence and one named verdict instead of a summed score, ADR-0008), `author-calibrated-eval` (intent alignment: the author's own blind reading is the ground truth for LLM-written prose), `verify-bootstrap` (machine gates as the enforcer of LLM-first readability, ADR-0025), `measurement-discipline` (evidence discipline that supports Measure). The repository is its own marketplace (`.claude-plugin/marketplace.json`, source `./`); the version lives in `.claude-plugin/plugin.json` and the history in [CHANGELOG.md](CHANGELOG.md).

**Sync model.** The canonical copies of the plugin skills live in the author's Claude Code harness (`~/.claude/`). This repository is a one-way mirror of them: `scripts/sync-from-local.sh` publishes a fixed allowlist, aborts if a listed skill is missing or lacks its `origin` marker, and never commits (`--dry-run` reports differences only). The rules file is not synced.

**Links.**

- [llms.txt](llms.txt) and [llms-full.txt](llms-full.txt): the machine-readable summary and the question-and-answer reference.
- [rules/common/akc-cycle.md](rules/common/akc-cycle.md): the rules file.
- [Agent Knowledge Cycle](https://github.com/shimo4228/agent-knowledge-cycle): ADRs, knowledge graph and citation metadata.
- Sibling research lines by the same author: [Contemplative Agent](https://github.com/shimo4228/contemplative-agent) ([DOI 10.5281/zenodo.19212118](https://doi.org/10.5281/zenodo.19212118)), autonomous agents grounded in four contemplative axioms; [Agent Attribution Practice](https://github.com/shimo4228/agent-attribution-practice) ([DOI 10.5281/zenodo.19652013](https://doi.org/10.5281/zenodo.19652013)), harness-neutral ADRs on accountability distribution.

</details>
