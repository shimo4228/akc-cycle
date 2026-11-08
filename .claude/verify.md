# 機械ゲートの選定記録 (akc-cycle)

入口は [`verify.sh`](verify.sh)（`--staged` = commit 境界 / 引数なし = 全体）。CI は
[`.github/workflows/verify.yml`](../.github/workflows/verify.yml) が同じ入口を引数なしで呼ぶ。
内容を変えたら承認台帳（`~/.claude/scripts/hooks/verify_allow.py`）で再承認が要る。

選定日: **2026-11-08**。この repo の `skills/` は `~/.claude`（harness）の正本からの一方向の写しで、
コードの直し先は harness。道具と pin は **harness の `.claude/verify.md` の選定（2026-07-31 選定、
2026-08-28 audit）をそのまま使う** — 写しを正本と別の道具で判定すると、正本では緑の写しが
ここで赤くなる。2026-11-08 時点で harness 側の再調査トリガー（12 ヶ月経過 / ty 1.0 / 代替の出現）は
未到来なので、search-first の引き直しはしていない。

## category 別

| category | tool | mode | 判定 |
|---|---|---|---|
| consistency | verify.sh 内の stdlib Python（下記） | staged + full | block |
| format | ruff ==0.16.5 format（各 sub-project の pyproject、無ければ root `ruff.toml`） | staged + full | block |
| lint | ruff ==0.16.5 check（select 明示 pin、harness と同一） | staged + full | block |
| 予算系 lint | ruff C901=15（harness の分布実測 2026-08-28: p99=13） | staged + full | block |
| shell | shellcheck `--norc -S style -e SC1091`（CI は shellcheck-py ==0.11.0.1） | staged + full | block |
| type check | ty ==0.0.75（sub-project 単位、`.venv` を `uv sync` で用意） | full | block |
| test | pytest（`skills/*/tests` を持つ sub-project 単位、`uv run`） | full | block |
| security | secret scan はローカル hook（staged）と CI の gitleaks（全履歴） | — | 別建て |
| dependency | — | — | **該当なし**（実行時依存は skill-comply の pyyaml のみ、uv.lock で固定） |

## consistency（この repo 固有）

写しと manifest・README の食い違いを検査する。1.7.0 と 1.8.0 の 2 版にわたって
`gemini-extension.json` の version が 1.6.6 のまま残り、README の数値が古いまま残った
（2026-11-08 に発見）ことを受けて置いた。

- `plugin.json` と `gemini-extension.json` の version が一致し、`CHANGELOG.md` にその版の節がある
- `skills/` のディレクトリ集合と `scripts/sync-from-local.sh` の `SKILLS` allowlist が一致する
- `README.md` が `skills/` の全 skill をバッククォート付きの名前で名指している

README の文章の正しさ（文字数の目安・説明文）は機械で見ていない — skill 構成が変わる版で人が読む。

検査コードは verify.sh に埋め込んでいる。承認台帳が pin するのは verify.sh のバイト列だけなので、
別ファイルに分けると承認の外で実行される。

## 予算系

ファイル LOC と C901 の閾値は harness 側で実測・管理している（コードの変更は harness で起き、
そこで先に判定される）。この repo では C901 だけを sub-project の pyproject 経由で同じ値で判定し、
LOC は持たない。

再調査: harness の `.claude/verify.md` の選定が変わったとき（pin をそこに揃える）/ この repo に
写しでないコードが入ったとき。
