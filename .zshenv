# .zshenv — **すべての zsh が読む**(対話でなくても、ログインでなくても)。
#
# .zshrc は対話シェルしか読まない。つまり `zsh -c '...'`、スクリプトの shebang、
# ssh 越しの単発実行では PATH も mise も効いていなかった。ここに置くのは
# 「環境」だけで、打鍵の便利さ(alias・キーバインド・補完)は .zshrc に残す
# —— 2026-08-15 に立てた「環境と打鍵を混ぜない」の、最後の一歩。

# path と PATH を連動させ、重複を自動で落とす(-U = unique)。
# 同じ .zshenv が二度読まれても PATH が伸びない。
typeset -U path PATH

path=(
  ~/.local/bin
  ~/bin
  $path
)

# mise の shims。
#
# 対話シェルでは .zshrc の `mise activate zsh` が働き、ディレクトリごとに
# PATH を差し替える。**非対話シェルはそれを走らせない**ので、shims を置いて
# おかないとスクリプトがシステムの node を掴む。activate が効いている場合は
# installs/ 側が前に来るので、shims は「効いていないときの受け皿」。
[[ -d ~/.local/share/mise/shims ]] && path=(~/.local/share/mise/shims $path)

export PATH
