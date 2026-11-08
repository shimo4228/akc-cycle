#!/usr/bin/env bash
# .claude/verify.sh — akc-cycle repo の機械ゲート、唯一の入口。
#
# 契約 (skill: verify-bootstrap が正本):
#   引数     --staged = commit 境界の高速検査 (staged ファイルのみ、数秒)
#            引数なし  = repo 全体の完全検査 (pytest / ty を含む)
#   環境     VERIFY_REPO_ROOT があれば repo root として使う (承認機構が渡す)
#   exit     0 = PASS / 1 = FAIL (commit を止める) / 2 = 検査不能 (fail-soft)
#   stdout   FAIL 時は人間と LLM が読んで直せる検出行。PASS 時は眠っているゲートの通知だけ
#
# この repo の skills/ は ~/.claude (harness) の正本からの一方向の写し。コードの直し先は harness で、
# 道具と pin は harness の .claude/verify.md の選定をそのまま使う (選定記録は .claude/verify.md)。
# この repo 固有に持つのは「写しと manifest・README の食い違い」の検査 (consistency 段)。
#
# 検査対象のパスは repo が制御する入力なので、配列 + `--` で渡す (単語分割で option を注入されない)。
# bash 3.2 (macOS /bin/bash) 互換: mapfile を使わず、空配列は展開しない (collect が偽を返す)。

set -uo pipefail

if [[ -n "${VERIFY_REPO_ROOT:-}" ]]; then
  ROOT="$VERIFY_REPO_ROOT"
else
  ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P) || exit 2
fi
git -C "$ROOT" rev-parse --show-toplevel >/dev/null 2>&1 || { echo "[verify] git repo ではない: $ROOT"; exit 2; }
cd "$ROOT" || exit 2

MODE=full
[[ "${1:-}" == "--staged" ]] && MODE=staged

FAIL=0
warn() { printf '%s\n' "$*"; }
check() {
  local label=$1 out
  shift
  if out=$("$@" 2>&1); then
    return 0
  fi
  printf '[%s] %s\n' "$label" "$out"
  FAIL=1
}

collect() {
  SELECTED=()
  local line
  while IFS= read -r line; do
    [[ -n "$line" && -f "$ROOT/$line" ]] && SELECTED+=("$line")
  done
  [[ ${#SELECTED[@]} -gt 0 ]]
}

# staged: index の追加・変更分。full: tracked + untracked (.gitignore は尊重)
files() {  # $@ = pathspec
  if [[ "$MODE" == staged ]]; then
    git diff --cached --name-only --diff-filter=ACMR -- "$@"
  else
    git ls-files --cached --others --exclude-standard -- "$@"
  fi
}

if command -v uvx >/dev/null 2>&1; then
  UVX=$(command -v uvx)
elif [[ -x "$HOME/.local/bin/uvx" ]]; then
  UVX="$HOME/.local/bin/uvx"
else
  echo "[verify] uvx が無いため Python ゲートを実行できません (brew install uv)"
  exit 2
fi
RUFF=("$UVX" 'ruff==0.16.5')
TY=("$UVX" 'ty==0.0.75')  # 0.0.x なので版 pin 必須 (1.0 前は patch で診断が増減する)
SHELLCHECK=(shellcheck --norc -S style -e SC1091)

# ---- consistency: 写し・manifest・README の食い違い (stdlib のみ、1 秒未満なので staged でも回す)
# 1) plugin.json と gemini-extension.json の version が一致し、CHANGELOG にその版の節がある
# 2) skills/ のディレクトリ集合 == scripts/sync-from-local.sh の SKILLS allowlist
# 3) README.md が skills/ の全 skill を `name` の形で名指している
check consistency python3 -I - <<'PY'
import json, pathlib, re, sys
root = pathlib.Path(".")
errs = []
pv = json.loads((root / ".claude-plugin/plugin.json").read_text())["version"]
gv = json.loads((root / "gemini-extension.json").read_text())["version"]
if pv != gv:
    errs.append(f"version 不一致: .claude-plugin/plugin.json={pv} / gemini-extension.json={gv}")
if not re.search(rf"^## \[{re.escape(pv)}\]", (root / "CHANGELOG.md").read_text(), re.M):
    errs.append(f"CHANGELOG.md に '## [{pv}]' の節が無い")
dirs = {p.parent.name for p in (root / "skills").glob("*/SKILL.md")}
m = re.search(r"^SKILLS=\((.*?)\)", (root / "scripts/sync-from-local.sh").read_text(), re.S | re.M)
allow = set(m.group(1).split()) if m else set()
if not m:
    errs.append("scripts/sync-from-local.sh に SKILLS=(...) が見つからない")
for s in sorted(dirs - allow):
    errs.append(f"skills/{s} が sync allowlist (scripts/sync-from-local.sh SKILLS) に無い")
for s in sorted(allow - dirs):
    errs.append(f"sync allowlist の {s} が skills/ に無い")
readme = (root / "README.md").read_text()
for s in sorted(dirs):
    if f"`{s}`" not in readme:
        errs.append(f"README.md が skill `{s}` を名指していない")
if errs:
    print("\n".join(errs))
    sys.exit(1)
PY

# ---- Python: format / lint (設定は各 sub-project の pyproject、無ければ root の ruff.toml)
if collect < <(files '*.py'); then
  check format "${RUFF[@]}" format --check -- "${SELECTED[@]}"
  check lint   "${RUFF[@]}" check --no-cache -- "${SELECTED[@]}"
elif [[ "$MODE" == full ]]; then
  echo "[verify] full mode で .py が 0 件 — 選別が壊れている"
  FAIL=1
fi

# ---- shell
if collect < <(files '*.sh'); then
  if command -v shellcheck >/dev/null 2>&1; then
    check shellcheck "${SHELLCHECK[@]}" -- "${SELECTED[@]}"
  else
    warn "[verify] shellcheck 不在 — shell lint をスキップ (brew install shellcheck)"
  fi
fi

[[ "$MODE" == staged ]] && exit $FAIL

# ---- full only: sub-project ごとの pytest と ty。実行するのは index を通った project だけ
# (untracked のまま置かれた conftest.py / build hook を無人で実行しない)
if ! command -v uv >/dev/null 2>&1; then
  warn "[verify] uv 不在 — sub-project の pytest / ty をスキップ"
else
  while IFS= read -r manifest; do
    [[ -n "$manifest" ]] || continue
    proj=$(dirname "$manifest")
    [[ -d "$ROOT/$proj" ]] || continue
    if [[ -d "$ROOT/$proj/tests" ]]; then
      check "pytest($proj)" uv run --quiet --project "$ROOT/$proj" --directory "$ROOT/$proj" pytest -q
    fi
    if [[ ! -d "$ROOT/$proj/.venv" ]] && ! uv sync --project "$ROOT/$proj" --quiet 2>/dev/null; then
      warn "[verify] ty($proj) — .venv を用意できず型検査をスキップ (uv sync で作れます)"
      continue
    fi
    check "ty($proj)" "${TY[@]}" check --project "$ROOT/$proj"
  done <<< "$(git ls-files --cached -- 'skills/*/pyproject.toml')"
fi

exit $FAIL
