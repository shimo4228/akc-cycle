#!/usr/bin/env bash
# sync-from-local.sh — one-way export from the live Claude Code harness
# (~/.claude) into this rules-file repo.
#
# This is the rule-repo variant of the skill-repo sync script. It publishes
# exactly one harness-canonical rule file: rules/common/akc-cycle.md. The
# harness copy must exist and carry the expected origin marker; otherwise the
# script aborts (it never silently drops the published rule). Root files
# (README, LICENSE, llms*.txt, CHANGELOG) are never touched. The script never
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

# the single rule file this repo publishes, relative to repo root / harness root
REL_PATH="rules/common/akc-cycle.md"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]] && DRY_RUN=1

SRC="$SOURCE_DIR/$REL_PATH"
DST="$TARGET_DIR/$REL_PATH"

# --- guard: harness copy must exist and declare the expected origin ---
if [[ ! -f "$SRC" ]]; then
  echo "ABORT: $SRC not found — harness copy missing for published rule." >&2
  exit 1
fi
# read the header into a variable first: piping head into grep can take head's
# SIGPIPE exit under `set -o pipefail` and spuriously fail; -F matches literally
# so an overridden ORIGIN cannot act as a regex.
header="$(head -15 "$SRC")"
if ! grep -qF "origin: $ORIGIN" <<<"$header"; then
  echo "ABORT: $SRC does not declare 'origin: $ORIGIN'." >&2
  exit 1
fi

# --- guard: rules/ must be clean so the sync delta is reviewable ---
if (( ! DRY_RUN )); then
  if ! git -C "$TARGET_DIR" diff --quiet -- rules ||
     ! git -C "$TARGET_DIR" diff --cached --quiet -- rules; then
    echo "ABORT: uncommitted changes in rules/ — commit or stash first," >&2
    echo "       so that 'git diff' after sync shows exactly the sync delta." >&2
    exit 1
  fi
fi

# --- secret scan (high-confidence patterns; abort on any hit) ---
SECRET_RE='sk-ant-api[0-9A-Za-z_-]+|ghp_[0-9A-Za-z]{36}|github_pat_[0-9A-Za-z_]{20,}|AKIA[0-9A-Z]{16}|xox[bporas]-[0-9A-Za-z-]{10,}|AIza[0-9A-Za-z_-]{35}|hf_[A-Za-z]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY'
# fail closed: grep exit 0 = match (abort), 1 = clean, >=2 = scan error (abort —
# never publish a file we could not verify).
scan_status=0
grep -Eq "$SECRET_RE" "$SRC" || scan_status=$?
if (( scan_status == 0 )); then
  echo "ABORT: potential secret detected in $SRC." >&2
  exit 1
elif (( scan_status >= 2 )); then
  echo "ABORT: secret scan errored (grep exit $scan_status) — cannot verify $SRC is clean." >&2
  exit 1
fi

# --- report / apply ---
if (( DRY_RUN )); then
  echo "# DRY-RUN (origin: $ORIGIN) — differences harness vs $TARGET_DIR"
  if [[ -f "$DST" ]]; then
    diff -u "$DST" "$SRC" || true
  else
    echo "# TARGET MISSING — would create $DST"
    diff -u /dev/null "$SRC" || true
  fi
  exit 0
fi

mkdir -p "$(dirname "$DST")"
cp "$SRC" "$DST"

echo "# APPLIED (origin: $ORIGIN). Review before committing:"
git -C "$TARGET_DIR" status --short
