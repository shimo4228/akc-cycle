# akc-cycle rules 二版化 — 自己完結版 + ポインター版

## Context

`~/.claude/rules/common/akc-cycle.md`（ローカル rule）と `~/MyAI_Lab/akc-cycle/rules/common/akc-cycle.md`（配布 repo）は現在 **byte 同一の 40 行圧縮版**。「6 phase の手順は各 skill が持つ」「自己完結版は AKC repo が正本」と書いてあるが、自己完結版はどこにも存在しない（記述と実体の乖離）。harness ADR-0018 L84 / ADR-0035 Decision 6 は「圧縮版を配布 repo へ同期しない」と決めたが、`sync-from-local.sh` は rule を allowlist に含めて同期しており実態が逆転している。

さらに AKC v2.5.0〜v2.7.0 で入った機構（ADR-0022 transfer 完了テスト / 0023 負の極 / 0024 三役ループ / 0025 LLM-first / 0026 expiry-conditioned / 0027 mental model・instance）が rule 側に反映されていない。

**決定（ユーザーと合意済み）**: 二版化する。
- **自己完結版**（配布 repo 所有）— skill 未導入環境でも cycle が回る floor。6 phase 表と機構更新を全登載
- **ポインター版**（ローカル harness 正本）— 重複なし設計を保ち、全機構を「所有者へのポインター」として登載。自身が所有する Scaffold Dissolution 節だけ判定基準（0022/0023）を実体で持つ

## 変更ファイル

### 1. ポインター版: `~/.claude/rules/common/akc-cycle.md`（ローカル正本）

構成（現行 3 節を保持しつつ再構築、~55 行）:

- **frontmatter**（HTML コメント 3 行形式を維持）
  - rationale: ADR-0018 + ADR-0035 + 二版化（2026-09-01）を反映
  - review-when: 現行条件 + 「ポインター先の skill / rule が改廃された時」
- **冒頭 — 全機構ポインター表**（新設。「自己完結版は AKC repo が正本」の一文を置換）

  | 機構 | 所有者 |
  |---|---|
  | 6 phase 手順 | Research→skill: `search-first` / Extract→`learn-eval` / Curate→`skill-health`+`skill-stocktake`+`rules-stocktake`+`agent-stocktake` / Promote→`rules-distill` / Measure→`skill-comply` / Maintain→`context-sync`+`repo-asset-stocktake`（mutable snapshot — AKC ADR-0019） |
  | 三役ループ judge/build/human（AKC ADR-0024） | skill: `task-triage`、rule: `planning.md` |
  | LLM-first artifact readability（AKC ADR-0025） | rule: `llm-first-code.md` |
  | expiry-conditioned knowledge（AKC ADR-0026） | rule: `knowledge-staleness.md` + 本 rule の「ADR も足場」「却下記録の読み方」節 |
  | mental model / instance（AKC ADR-0027） | AKC repo の CLAUDE.md（harness rule の対象外） |
  | 自己完結版（skill 未導入環境向け） | akc-cycle repo `rules/common/akc-cycle.md`（本ファイルとは別内容 — 二版化 2026-09-01） |

- **Scaffold Dissolution 節** — 現行の inward / downward / モデル世代交代に加え、判定基準 2 点を追記（重複でなく欠落の補充）:
  - **transfer 完了テスト**（AKC ADR-0022）: 同一文脈 ablation 判別不能は必要証拠止まり。溶かしてよい完了証拠は held-out transfer（scaffold 無しの新文脈で挙動が再現すること）
  - **負の極**（AKC ADR-0023）: 負の情報差分を持つ artifact（古い既定を上書きする drift した rule 等）は放置でなく積極削除。沈黙・ablation・transfer は「不在」しか検出できないため、モデル世代交代時に generation review で負の差分を監査する（既存の `generation-audit` 参照に接続）
- **「ADR も足場である」「却下記録の読み方」節** — 現行のまま保持（AKC ADR-0026 のローカル instance として機能済み）

### 2. 自己完結版: `~/MyAI_Lab/akc-cycle/rules/common/akc-cycle.md`（配布 repo 所有に変更）

英語で書き直す（配布 repo は英語正本 — README / llms.txt と整合）。skill 名を前提にしない harness-agnostic な floor、~90 行:

- frontmatter: `<!-- origin: shimo4228 -->`（sync 対象外化に伴い rationale/review-when はローカル形式でなく簡素に）
- **6 phase 表**: Phase / Principle / Trigger — README.md:36-43 の表を rule 本文に正式収載（各 phase の behavioral principle として、skill 無しで会話内実行できる粒度の 1-2 行ずつ）
- **Scaffold Dissolution**: inward / downward / model-generation turnover の 3 トリガー + transfer 完了テスト（0022）+ 負の極（0023）
- **Expiry-conditioned knowledge**（0026 digest): 保存判断は失効条件を持つ / 失効条件の無い推奨は弱く扱う / 却下記録も日付つき仮説、supersede が正常系、削除でなく日付つき注記
- **Three-role attention topology**（0024 digest): judge が前提検証・worth-doing・検収でモデル判断を消費し human 判断を節約 / build が実装 / human は方向性と merge の binary gate のみ。「上流に移るのは attention であって authority ではない」
- **LLM-first readability**（0025 digest): cycle artifact の既定読者は次セッションの LLM / 保存するのは verifiability（型・テスト・golden・invariant）/ 人間 prose 予算は README と出力文面のみ

### 3. sync script 除外: `~/MyAI_Lab/akc-cycle/scripts/sync-from-local.sh`

rule ファイルを配布 repo 所有に切り替え、同期対象から除外:
- L31 `RULE_REL` と L61 の `require`、L78/L80 の staging コピーを削除
- L35 `SUBTREES=(rules skills agents)` → `(skills agents)`（rules/ subtree は script が rm -rf しなくなる）
- ヘッダコメント（L5-8）を「rules ファイルは repo 所有（自己完結版）。plugin payload の skills/agents のみ同期」に更新

### 4. 整合更新

- `~/MyAI_Lab/akc-cycle/README.md`: Path 1 の説明を「self-contained floor（repo 所有、harness と別版）」に更新。「Syncing from the harness」節から rule file を除外。6 phase 表は rule 本文と一致させる。**加えてポインター版へのリンクを置く**: 「著者の live harness では skill 導入済み環境向けの pointer edition が動いている」として claude-harness 公開 copy（`shimo4228/claude-harness` の `rules/common/akc-cycle.md`）へリンク（ADR-0027 の grounding — running instance の第一級リンク）
- `~/MyAI_Lab/akc-cycle/CHANGELOG.md` にエントリ追加、`llms.txt` / `llms-full.txt` の rule 記述を確認・更新
- harness `~/.claude/docs/adr/0035-commit-review-hook-and-rules-rightsize.md` Decision 6 に日付つき注記: 「2026-08-27 の sync で drift（圧縮版が配布 repo に同期されていた）→ 2026-09-01 二版化で元判断に復帰、配布版は自己完結版として独立」。ADR-0018 L84 にも同旨の 1 行注記
- AKC repo `docs/akc-cycle.md`（ポインタ文書）: 二版化を反映し **両版へのリンクを併記** — 自己完結版（akc-cycle repo、skill 未導入環境の install target）とポインター版（claude-harness、skill 導入済み環境の running instance）。どちらを install するかの 1 行ガイド付き

### 5. 後続（このプランの外、実施後にユーザー判断）

- `skill: harness-sync` で claude-harness 集約 repo へローカル版を同期
- akc-cycle repo の commit & push（sync script は commit しない設計 — git diff がレビューゲート）

## Verification

1. `diff ~/.claude/rules/common/akc-cycle.md ~/MyAI_Lab/akc-cycle/rules/common/akc-cycle.md` — 意図的に異なることを確認
2. `~/MyAI_Lab/akc-cycle/scripts/sync-from-local.sh --dry-run` — rules/ が diff 対象外になり、skills/agents のみ報告されること
3. harness の rule lint（`~/.claude/scripts/harness_lint.py` 相当）を実行し frontmatter 3 フィールドが通ること
4. ポインター表の skill / rule 名が実在することを grep で照合（`agent-stocktake` / `task-triage` 等）
