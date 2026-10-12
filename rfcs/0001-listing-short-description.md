---
state: blocked 2026-10-12
---
## Summary

plugin directory の listing を、入れた人が最初に打つコマンドが分かる形にする。`plugin.json` の `description`（directory の short description）を 1 段落から 1 行にし、`documentationUrl` と `supportUrl` を足す。README の「"audit my skills" と頼めば skill-stocktake が動く」という記述を、コマンドで呼ぶ書き方に直す。変更は branch `listing-short-description`（34302b0）に用意してあり、v1.5.0 が directory で live になってから次の版として出す。

## Motivation

- 2026-10-12 の owner console（Usage タブ、30 日、data through 2026-10-10）: インストール 268（266 アカウント）、使っているアカウント 3（28 日）、使用 3（読み込まれたセッション 3,490）。入れてもらうところまでは届いていて、使われるところで止まっている
- directory は live の版の `plugin.json` の `description` を short description として出す。今の文は 1 段落（約 700 字）で、何を打てば何が起きるかが書いていない
- README の冒頭と Install 節は「"audit my skills" と頼めば動く」と書いているが、その言い方では skill は発火しない（著者の観察、2026-10-12）。plugin の skill は `/akc-cycle:<skill名>` で呼ぶのが確実な入口
- directory は README を listing の長い説明として出すので、README の記述のずれは listing のずれでもある

## Reference-level explanation

- `.claude-plugin/plugin.json`:
  - `description`: `Skills that audit and prune the skills, rules and docs in your Claude Code setup. Start with /akc-cycle:skill-stocktake.`
  - 追加: `documentationUrl`（`https://github.com/shimo4228/akc-cycle#readme`）、`supportUrl`（`https://github.com/shimo4228/akc-cycle/issues`）
- `README.md`: 3 行目と 30 行目の「"audit my skills"」の言い回しを外し、`/akc-cycle:skill-stocktake` を名指す
- 仕様の照合（公式 doc「Manage your listing after publishing」、Claude Code の plugin manifest reference、as-of 2026-10-12）:
  - 掲載後に live の版に追従するのは、名前と short description（`plugin.json` と README から）だけ
  - `icon`、`documentationUrl`、`supportUrl`、`privacyPolicyUrl`、`termsOfServiceUrl` は、申請したときだけ読まれる。この repo の申請は 2026-07-15 で、そのときの `plugin.json` にはアイコンなどが無かったので、portal の Listing タブではアイコン・作成者・keywords が空のまま
  - よって今回足す URL 欄は、manifest に揃えておくだけで、listing には反映されない
- 版: release のときに `version` を上げ、CHANGELOG に書く

## Rationale and alternatives

- **v1.5.0 を待たずに出す**: v1.5.0 は検査を通って Anthropic の reviewer 待ち。より新しい commit を出すと、待っている依頼がどう扱われるかは doc から読めないので、待つ
- **Anthropic に申請時の欄の更新を頼む**: 頼まない（著者の判断、2026-10-12）
- **自然文の呼び方を README に残す**: skill の自発的な発火は確率的で、その言い方では動かなかったので残さない

## Status

blocked — 変更は branch `listing-short-description` に用意済み。v1.5.0 の公開待ち（2026-10-12）。

## Next action

```
再開条件: akc-cycle の v1.5.0 が directory で live になる
照合先:   claude.ai/directory/manage の akc-cycle のページの「Live now」欄
成立時:   accepted（branch を main に入れ、version を上げ、CHANGELOG を書いて push する）
```
