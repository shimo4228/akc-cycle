#!/usr/bin/env bash
# sync-from-local.sh — one-way export from the live Claude Code harness
# (~/.claude) into this repo.
#
# akc-cycle variant: publishes the single harness-canonical rule file
# (rules/common/akc-cycle.md) PLUS the fixed AKC-cycle plugin payload — the
# nine cycle-phase skills and the two subagents they invoke — so this repo
# doubles as a Claude Code plugin (see .claude-plugin/). Unlike the aggregate
# claude-harness sync, the published set is an explicit allowlist, not an
# origin sweep: every listed component must exist in the harness and declare
# the expected origin marker, or the script aborts (it never silently drops a
# published component). Root files (README, LICENSE, llms*.txt, CHANGELOG)
# and the .claude-plugin/ manifests are never touched. The script never
# commits — `git diff` in this repo is the review gate.
#
# Usage:
#   scripts/sync-from-local.sh --dry-run   # report differences only
#   scripts/sync-from-local.sh             # apply to working tree
#
# Config (env overrides):
#   HARNESS_SYNC_SOURCE  source harness dir      (default: ~/.claude)
#   HARNESS_SYNC_ORIGIN  origin value to require (default: shimo4228)

set -euo pipefail

SOURCE_DIR="${HARNESS_SYNC_SOURCE:-$HOME/.claude}"
ORIGIN="${HARNESS_SYNC_ORIGIN:-shimo4228}"
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# the fixed published set (allowlist), relative to harness root / repo root
RULE_REL="rules/common/akc-cycle.md"
SKILLS=(search-first learn-eval skill-stocktake skill-health rules-stocktake
        rules-distill skill-comply context-sync repo-asset-stocktake)
AGENTS=(adr-writer codemap-writer)
SUBTREES=(rules skills agents)

DRY_RUN=0
[[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]] && DRY_RUN=1

# read the header into a variable first: piping head into grep can take head's
# SIGPIPE exit under `set -o pipefail` and spuriously fail; -F matches literally
# so an overridden ORIGIN cannot act as a regex.
has_origin() {
  local header
  header="$(head -15 "$1")"
  grep -qF "origin: $ORIGIN" <<<"$header"
}

# --- guard: every published component must exist and declare the origin ---
require() {
  if [[ ! -f "$1" ]]; then
    echo "ABORT: $1 not found — harness copy missing for published component." >&2
    exit 1
  fi
  if ! has_origin "$1"; then
    echo "ABORT: $1 does not declare 'origin: $ORIGIN'." >&2
    exit 1
  fi
}

require "$SOURCE_DIR/$RULE_REL"
for s in "${SKILLS[@]}"; do require "$SOURCE_DIR/skills/$s/SKILL.md"; done
for a in "${AGENTS[@]}"; do require "$SOURCE_DIR/agents/$a.md"; done

# --- guard: managed subtrees must be clean so the sync delta is reviewable ---
if (( ! DRY_RUN )); then
  if ! git -C "$TARGET_DIR" diff --quiet -- "${SUBTREES[@]}" ||
     ! git -C "$TARGET_DIR" diff --cached --quiet -- "${SUBTREES[@]}"; then
    echo "ABORT: uncommitted changes in ${SUBTREES[*]} — commit or stash first," >&2
    echo "       so that 'git diff' after sync shows exactly the sync delta." >&2
    exit 1
  fi
fi

# --- staging ---
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
mkdir -p "$STAGING/rules/common" "$STAGING/skills" "$STAGING/agents"

cp "$SOURCE_DIR/$RULE_REL" "$STAGING/$RULE_REL"
for s in "${SKILLS[@]}"; do cp -R "$SOURCE_DIR/skills/$s" "$STAGING/skills/"; done
for a in "${AGENTS[@]}"; do cp "$SOURCE_DIR/agents/$a.md" "$STAGING/agents/"; done

# --- prune runtime artifacts from the staged payload ---
find "$STAGING" \( -name results.json -o -name '*.log' -o -name '*.pyc' \
  -o -name .DS_Store -o -name .coverage -o -name '.coverage.*' \) -delete
find "$STAGING" \( -name __pycache__ -o -name .pytest_cache -o -name .venv \
  -o -name node_modules -o -name .mypy_cache -o -name .ruff_cache \
  -o -name htmlcov -o -name results \) -type d -prune -exec rm -rf {} + 2>/dev/null || true
# `results` is skill-comply's run-output directory (generated specs + reports).
# The gitignore-honoring prune only catches what the source repo declines to track
# (results/*.md); the generated *.spec.yaml files ARE tracked upstream, so they rode
# into the payload — measurement records of the author's own skills, which a consumer
# never uses. The aggregate claude-harness script already pruned this; the fix had not
# propagated to the vendored copies (2026-08-15).

# --- honor each skill's own .gitignore (structural, not pattern-enumerated) ---
# The harness copy is staged with a plain cp -R, which is not git-aware: runtime
# output a skill gitignores locally (e.g. skill-comply results/*.md, which carry
# personal paths) would otherwise ride into the published payload. Simple glob
# patterns only (no negation / **), which covers the harness skills' ignores.
prune_gitignored() {
  local dir="$1" pat
  [[ -f "$dir/.gitignore" ]] || return 0
  while IFS= read -r pat; do
    pat="${pat%$'\r'}"
    [[ -z "$pat" || "$pat" == \#* || "$pat" == \!* ]] && continue
    pat="${pat%/}"
    (
      cd "$dir"
      shopt -s nullglob dotglob
      # shellcheck disable=SC2086  # intentional glob expansion of the pattern
      rm -rf -- $pat
    )
  done <"$dir/.gitignore"
}
for d in "$STAGING"/skills/*/; do prune_gitignored "$d"; done
find "$STAGING" -type d -empty -delete

# --- frontmatter YAML validation (GitHub / plugin loaders parse strictly; abort on invalid) ---
if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
  python3 - "$STAGING" <<'PYEOF' || exit 1
import glob, re, sys
import yaml
bad = []
for path in sorted(glob.glob(f"{sys.argv[1]}/**/*.md", recursive=True)):
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    m = re.match(r"^---\n(.*?)\n---(\n|$)", text, re.S)
    if not m:
        continue
    try:
        yaml.safe_load(m.group(1))
    except yaml.YAMLError as exc:
        bad.append(f"  {path}: {str(exc).splitlines()[0]}")
if bad:
    print("ABORT: invalid YAML frontmatter in staged payload"
          " (strict parsers like GitHub's will fail to render):", file=sys.stderr)
    print("\n".join(bad), file=sys.stderr)
    sys.exit(1)
PYEOF
else
  echo "WARN: python3 + PyYAML not available — skipping frontmatter YAML validation" >&2
fi

# --- secret scan (high-confidence patterns; abort on any hit) ---
SECRET_RE='sk-ant-api[0-9A-Za-z_-]+|ghp_[0-9A-Za-z]{36}|github_pat_[0-9A-Za-z_]{20,}|AKIA[0-9A-Z]{16}|xox[bporas]-[0-9A-Za-z-]{10,}|AIza[0-9A-Za-z_-]{35}|hf_[A-Za-z]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY'
if hits="$(grep -rEl "$SECRET_RE" "$STAGING" 2>/dev/null)"; then
  echo "ABORT: potential secrets detected in staged payload:" >&2
  echo "$hits" >&2
  exit 1
fi

# --- report / apply ---
if (( DRY_RUN )); then
  echo "# DRY-RUN (origin: $ORIGIN) — differences staging vs $TARGET_DIR"
  for t in "${SUBTREES[@]}"; do
    diff -rq "$STAGING/$t" "$TARGET_DIR/$t" 2>/dev/null || true
  done
  exit 0
fi

for t in "${SUBTREES[@]}"; do
  rm -rf "${TARGET_DIR:?}/$t"
done
cp -R "$STAGING"/. "$TARGET_DIR"/

echo "# APPLIED (origin: $ORIGIN). Review before committing:"
git -C "$TARGET_DIR" status --short
