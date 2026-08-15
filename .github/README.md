# dotfiles_yadm

yadm で管理する個人 dotfiles。macOS と Ubuntu(WSL2 含む)で共通。

## セットアップ

```bash
yadm clone git@github.com:makit0sh/dotfiles_yadm.git
yadm config local.class personal   # 仕事のマシンなら work
yadm bootstrap
```

`bootstrap` は macOS なら `~/.Brewfile`、Linux なら `~/.config/apt/packages.txt`
を流し、どちらでも mise でランタイムを入れ、vim プラグインを入れる。
何度流しても安全。

前提は mise・Docker・pnpm の3つだけで、Homebrew(macOS)は先に入れておく。

## 何がどこに書いてあるか

| ファイル | 中身 |
| --- | --- |
| `~/.Brewfile` | macOS 固有のパッケージ |
| `~/.config/apt/packages.txt` | Linux 固有のパッケージ |
| `~/.config/mise/config.toml` | OS を跨いで同じ版が欲しいもの(node, rg, fzf, yazi …) |
| `~/.zshenv` | PATH と mise shims。非対話シェルにも効く |
| `~/.zshrc` | alias・キーバインド・補完。対話シェルのみ |
| `~/.config/ai/` | AI エージェントへの指示(AGENTS.md + stacks/) |

決めた理由は各ファイルのコメントに書いてある。

## 守ること

新しい CLI を足すときは、まず mise に置けないか考える。置ければ macOS と Linux の
リストを二重に保守しなくて済む。

**`~/.claude` を丸ごと `yadm add` しない。** `projects/` だけで 1.3GB あり、
中身は会話ログ。`~/.gitignore` が閉じてあるが、確認してから足すこと。

`~/.config/ai/` は個人の GitHub リポジトリで同期される。**雇用主固有の規約・
社内ツール・製品名をここに置かない。**

`.zshrc` の `ZSH_HUMAN` 分岐には、外れて困るものを入れない。判定は端末の有無と
環境変数による best-effort で、VSCode の Copilot は区別できない。

## このマシンだけの設定

追跡外なので `yadm diff` に出ない。試すときはここへ。

```
~/.zshenv.local     環境変数(非対話シェルにも効く)
~/.zshrc.local      alias やキーバインド
~/.vimrc.local
~/.gitconfig.local
```

## class

`yadm config local.class` で `personal` / `work` を切り替える。
`##class.*` が付いたファイルは、該当するものだけが展開される。

`.gitconfig` と `.claude/settings.json` は personal のみ。work では生成されないので、
そのマシンにある会社用の設定がそのまま残る。

## よく使う操作

```bash
plugin-update                  # zsh プラグインの更新(手動。自動にはしない)
brew bundle --global           # Brewfile を反映
mise install                   # mise の [tools] を反映
vim -es -u ~/.vimrc -c 'PlugInstall --sync' -c qa   # vim プラグイン(headless 可)
brew leaves                    # Brewfile との差分を見る
apt-mark showmanual            # packages.txt との差分を見る
```

## 困ったとき

| 症状 | 対処 |
| --- | --- |
| `pnpm` が Node のバージョンで文句を言う | リポジトリの外で叩いている。`cd` するか、activation が入っているか確認 |
| `[ERROR] This project requires Node.js …` | `mise install` してシェルを開き直す |
| `ERR_PNPM_ABORTED_REMOVE_MODULES_DIR_NO_TTY` | `CI=true pnpm install --frozen-lockfile`。ツールは `npx` ではなく devDependency + `pnpm exec` |
| `npx jest` が「No tests found」 | worktree の中にいる。`--testPathIgnorePatterns` で上書き |
| worktree で `pnpm <script>` が落ちる | worktree 内で `CI=true pnpm install --prefer-offline`。`node_modules` を symlink にしない |

## 腐らせないために

2025-03 から 2026-08 まで1年5ヶ月コミットされなかった。道具の問題ではないので、
`yadm status` をときどき見る。ツールが `.zshrc` に勝手に追記することがある
(Docker Desktop など)。採るか捨てるか決めてコミットする。
