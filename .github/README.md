# dotfiles_yadm

yadm で管理している個人 dotfiles。macOS / Ubuntu(WSL2 を含む)で共通。

## Install

```bash
yadm clone git@github.com:makit0sh/dotfiles_yadm.git
yadm config local.class personal   # 仕事のマシンなら work
yadm bootstrap
```

`bootstrap` は macOS なら `~/.Brewfile` を、Linux なら apt のリストを流し、
どちらでも `mise install` でランタイムを揃える。何度流しても安全。

## 構成の考え方

### バージョン管理されるもの / されないもの

`~/.gitignore` が「事故ると大きいもの」を明示的に閉めている。とくに
**`~/.claude/projects/` は 2026-08 時点で 1.3GB** あり、会話ログなので
機微な内容も入る。**`~/.claude` を丸ごと add しないこと。**

### ツールの入れ方は3層

| 層 | 持ち場 | 例 |
| --- | --- | --- |
| `~/.Brewfile` | **macOS 固有**の GUI とネイティブなもの | cask, ffmpeg, gcc |
| `bootstrap` の apt 節 | **Linux 固有 / OS に近いもの** | build-essential, zsh |
| `~/.config/mise/config.toml` | **OS を跨いで同じ版が欲しいもの** | node, python, uv |

新しい CLI を足すときは、**まず mise に置けないかを考える**。置ければ macOS と
Linux のリストを二重に保守しなくて済む。以前はこの逃がし先が無く、brew と apt に
同じようなリストが並んでいた。

`~/.Brewfile` の中身は `brew bundle dump` の出力ではなく **`brew leaves` から
手で選んだもの**。dump は依存まで書き出す(実測148行)ので、事故的に入った
ものまで新しいマシンへ運んでしまう。

### AI エージェントへの指示は `~/.config/ai/`

**エージェント非依存の指示テキストを1箇所に置き、各エージェントから参照する。**

```
~/.config/ai/core.md            言語・事実の扱い・検証・変更の出し方(スタック非依存)
~/.config/ai/stacks/*.md        node-web / cpp-embedded / ros2 / linux-kernel
        ↑ @import
~/.claude/CLAUDE.md             class によって読むスタックが変わる(中身は持たない)
```

`~/.claude/CLAUDE.md` は `##class.personal` / `##class.work` の2種類があり、
`yadm config local.class` で選んだほうが展開される。個人機は node-web を、
仕事機は cpp-embedded / ros2 / linux-kernel を読む。

**なぜ `~/.claude/` の中に直接書かないか:** 同じ指示を VSCode の Copilot からも
参照したいため。VSCode の Settings Sync は VSCode の中しか運べず、Claude Code は
その外にいるので、どちらかに閉じ込めると片方に届かない。**同期機構を統一する
のではなく、共有したい実体だけを外に出して両方から指させる。**

VSCode 自身の設定は Settings Sync に任せる(この dotfiles では扱わない)。
境界は「**VSCode の中の設定は Sync、AI への指示テキストは dotfiles**」。

> **仕事マシンの注意**: `~/.config/ai/` は個人の GitHub リポジトリで同期される。
> 雇用主固有の規約・社内ツール・製品名・コード片をここに置かないこと。
> 置いてよいのは「どこの職場でも通じる一般論」だけ。

### マシン差分は yadm alt

`##class.personal` / `##class.work` / `##os.Darwin` / `##os.Linux` を使う。
**絶対パスを設定ファイルに書かない** — `~/.claude/settings.json` の statusLine は
`/Users/t-maki/...` を直書きしていて Linux で必ず壊れる状態だったので、
スクリプトを `~/.local/bin/`(PATH 上)へ移し、コマンド名だけで解決するようにした。

## 腐らせないために

このリポジトリは 2025-03 から 2026-08 まで **1年5ヶ月コミットされなかった**。
道具の問題ではない(yadm は bare git そのもの)ので、運用側で気づけるようにする:

- `yadm status` に差分が溜まっていないか、ときどき見る
- ツールが `.zshrc` に勝手に追記することがある(Docker Desktop など)。
  採るか捨てるか決めてコミットする。放置すると「手で書いた設定」と区別が
  付かなくなり、コミットが億劫になる
