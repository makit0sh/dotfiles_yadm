# PATH は ~/.zshenv が通す(このファイルより先に、非対話シェルでも読まれる)。
#
# macOS のログインシェルでは /etc/zprofile の path_helper が .zshenv の**後**に
# 走って PATH を組み直すため、ここで一度だけ順序を戻す。順序が要るのは mise の
# shims と ~/.local/bin で、システムの同名コマンドに負けてはいけないもの。
typeset -U path PATH
path=(~/.local/bin ~/bin $path)
[[ -d ~/.local/share/mise/shims ]] && path=(~/.local/share/mise/shims $path)
export PATH

#
# 人間が打っているのか、エージェントが走らせているのか(以降で使うので最初に)
#
# Claude Code はこのファイルを読んだシェルのスナップショット
# (~/.claude/shell-snapshots/、2026-08 の実測で 8,816行・alias 16個)を作り、
# 以後のコマンドをその上で走らせる。つまり **ここに書いた alias と関数は
# エージェントの実行にそのまま乗る**。
#
# 判定は2段構え。
#
#   1. **TTY があるか。** 2026-08-15 に実測したところ、Claude Code のシェルは
#      stdin/stdout/stderr のどれも端末ではなかった。「人が打っている」とは
#      文字どおり「端末がある」ことなので、これが一番素直で、**どのエージェント
#      にも効く**(env 変数を付けてくれないツールにも効く)。CI・cron・
#      ssh の単発実行も同じ側に落ちる。
#   2. **既知のエージェント env。** PTY を割り当ててくるツール向けの補強。
#
# **それでも best-effort。** VSCode の統合ターミナルで Copilot が動かす場合、
# 端末は人が打つときと同じものなので、この2つでは区別できない(未確認)。
#
# したがって規則はこう:
#   - **外れると壊れるものを、この分岐の下に置かない。** 破壊的な alias
#     (`rm -i` など)や `cd` の上書きは、判定に関係なく撤去する
#   - この分岐に置いてよいのは、**外れても「起動が少し重い」で済むもの**だけ
#
# ZSH_HUMAN=0 を手で作れば、人間のシェルでもエージェント相当に落とせる。
if [[ ! -t 0 ]] ||
  [[ -n "$AI_AGENT" || -n "$CLAUDE_CODE_ENTRYPOINT" || -n "$CLAUDECODE" ]]; then
  ZSH_HUMAN=0
else
  ZSH_HUMAN=1
fi

##? Clone a plugin, identify its init file, source it, and add it to your fpath.
# borrowed from https://github.com/mattmc3/zsh_unplugged
function plugin-load {
  local repo plugdir initfile initfiles=()
  : ${ZPLUGINDIR:=~/.config/zsh/plugins}
  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules \
        https://github.com/$repo $plugdir
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) || { echo >&2 "No init file '$repo'." && continue }
      ln -sf $initfiles[1] $initfile
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

##? Update every cloned plugin. plugin-load only clones when the directory is
##? missing, so without this there is no path by which a plugin ever moves.
##? Measured 2026-08-15: everything here was from 2024, and zsh-completions —
##? which is a database of completions, so staleness means missing tools — was
##? 109 commits behind. Run it by hand now and then; it is not automatic
##? because a shell that updates plugins on startup is a shell that hangs on a
##? bad network.
function plugin-update {
  : ${ZPLUGINDIR:=~/.config/zsh/plugins}
  ##? These are shallow (--depth 1) clones, so `pull --ff-only` fails with
  ##? "Not possible to fast-forward" — the truncated histories diverge rather
  ##? than descend. They are read-only vendored copies, so fetch + hard reset
  ##? is both correct and simpler. It DOES discard local edits: patch a plugin
  ##? and you lose it here, which is the right trade for something you do not
  ##? own.
  local plugdir
  for plugdir in $ZPLUGINDIR/*(/N); do
    [[ -d $plugdir/.git ]] || continue
    echo "Updating ${plugdir:t}..."
    command git -C $plugdir fetch --quiet --depth 1 origin HEAD &&
      command git -C $plugdir reset --quiet --hard FETCH_HEAD &&
      command git -C $plugdir submodule --quiet update --init --recursive
  done
  echo "done. open a new shell to pick them up."
}

# fzf のキーバインドと補完(人間のときだけ。fzf 自体はコマンドとして常に使える)
#
# ここには以前「fzf が 0.48 より古ければ /usr/share/doc/fzf/examples/ を読む」
# という分岐があった。**その分岐が必要だった理由は apt の fzf が古いこと**で
# (Ubuntu 24.04 は 0.44.1、mise は 0.74.2)、fzf を mise に移した時点で
# 前提ごと消えたので分岐も消した。
#
# **存在確認は残す。** 2026-08-15 に Ubuntu コンテナで実測したとき、apt の
# リストから fzf を落としていたせいで `fzf --version` が command not found に
# なり、シェル起動のたびにエラーが2行出ていた。
if (( ZSH_HUMAN )) && command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

#
# mise (replaced asdf on 2026-08-15)
#
# asdf resolved tools through ~/.asdf/shims, a relay script, so `which node`
# never named the real binary. That opacity had real cost: repos carried
# workarounds that prepended an absolute install path ahead of the shims, and
# running pnpm outside a project dropped to whatever global asdf happened to
# have. mise rewrites PATH instead, reads the same .tool-versions files, and
# installs the same way on macOS and Linux.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

#
# plugins from github(打鍵の補助なので人間のときだけ)
#
if (( ZSH_HUMAN )); then
  repos=(
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-completions
    zsh-users/zsh-syntax-highlighting
    Aloxaf/fzf-tab
    trapd00r/LS_COLORS
  )

  plugin-load $repos
fi


# alias
alias c="clear"
alias cdd="cd ../"
alias cddd="cd ../../"
alias cdddd="cd ../../../"
alias ...='cd ../..'
alias ....='cd ../../..'
# macOS の BSD ls ではなく GNU ls(coreutils の gls)を使う。
# **存在確認をしてから alias する。** 無いまま alias すると `ls` が丸ごと壊れ、
# しかも chpwd フックが毎回 cd で呼ぶので、エラーが常時出る状態になる。
# 実際 2026-08-15 に `gls: cannot access ...` という形で表に出た。
if command -v gls >/dev/null 2>&1; then
  alias ls='gls --color=auto'
else
  alias ls='ls --color=auto'
fi
alias l='ls'
alias ll='ls -hl'
alias la='ls -a'
alias lla='ls -la'
alias vi='vim'

# `rm -i` / `mv -i` は撤去した(2026-08-15)。
#
# エージェントの実行には TTY が無いので、`-i` の確認プロンプトは EOF を読んで
# **「no」と解釈され、削除も上書きもせずに終了コード 0 を返す**。つまり
# エージェントは「消した」と報告し、ファイルは残る。**黙って間違った結果を出す**
# ので、ハングするより悪い。
#
# 人間に対しても `-i` は効いていない — 打鍵の速い人は確認に反射で y を打つ。
# うっかりを本当に防ぎたいなら、確認を挟むのではなく**戻せる場所に送る**こと。
# (`trash` 系コマンドを別名で足す案。今は入れていない)

# auto ls after cd — 人間のときだけ。
#
# 以前は `function cd(){ builtin cd $@ && ls; }` で cd 自体を上書きしていた。
# 関数はスナップショットに入るので、**エージェントの `cd` が毎回ディレクトリ
# 一覧を吐き**、本当の出力がその中に埋もれていた。chpwd フックなら cd の意味を
# 変えないし、この分岐が外れても害は「一覧が出る」だけで済む。
if (( ZSH_HUMAN )); then
  function chpwd() { ls }
fi

# bahavior
setopt no_beep

# history
#
# **エージェントのコマンドは履歴に残さない。** SHARE_HISTORY と
# INC_APPEND_HISTORY があると、エージェントが走らせた1コマンドごとに
# ~/.zsh_history へ書き込まれ、開いている他の端末にも共有される。2026-08-15 の
# 1セッションで数百件入り、**自分が打ったものを Ctrl-P で辿れなくなった**。
#
# HISTFILE を持たせないだけで、読み書きの両方が止まる。エージェントが何をしたか
# は各エージェント側のログ(~/.claude/projects 等)に残るので、失うものは無い。
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
if (( ZSH_HUMAN )); then
  HISTFILE="$HOME/.zsh_history"
  setopt EXTENDED_HISTORY
  setopt INC_APPEND_HISTORY
  setopt SHARE_HISTORY
else
  unset HISTFILE
fi

# vi like keybinds(打鍵の話なので人間のときだけ)
if (( ZSH_HUMAN )); then
  bindkey -v
  export KEYTIMEOUT=1 # kill the lag
  bindkey "^W" backward-kill-word    # vi-backward-kill-word
  bindkey "^H" backward-delete-char  # vi-backward-delete-char
  bindkey "^U" kill-line             # vi-kill-line
  bindkey "^?" backward-delete-char  # vi-backward-delete-char
fi

# changing directories
setopt AUTO_CD
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

# completion
# fpath has to be complete BEFORE compinit runs — anything appended afterwards
# is invisible to it. Docker Desktop appends its own block at the end of this
# file and then calls compinit a second time to compensate; the entry is folded
# in here instead so there is one compinit.
[[ -d ~/.docker/completions ]] && fpath=(~/.docker/completions $fpath)
autoload -Uz compinit
compinit
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 補完で大文字小文字を区別しない。
if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
setopt complete_in_word      # 語の途中でもカーソル位置で補完
setopt auto_param_slash      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt mark_dirs             # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt list_types            # 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
setopt auto_menu             # 補完キー連打で順に補完候補を自動で補完
setopt auto_param_keys       # カッコの対応などを自動的に補完
setopt interactive_comments  # コマンドラインでも # 以降をコメントと見なす
setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる

# expansion and globbing
setopt EXTENDED_GLOB
setopt NOMATCH

# color
autoload -Uz colors
colors

# history search(zle = 行編集なので、そもそも人間のときしか意味がない)
if (( ZSH_HUMAN )); then
  autoload -Uz history-search-end
  zle -N history-beginning-search-backward-end history-search-end
  zle -N history-beginning-search-forward-end history-search-end
  bindkey "^P" history-beginning-search-backward-end
  bindkey "^N" history-beginning-search-forward-end
  # bindkey "^R" history-incremental-search-backward
  # Ctrl-S は端末のフロー制御(XOFF)に取られていて、そのままだと押した瞬間に
  # 端末が固まる。バインドを効かせるには先に無効化が要る。
  stty -ixon 2>/dev/null
  bindkey "^S" history-incremental-search-forward
  bindkey "^[[A" history-beginning-search-backward-end
  bindkey "^[[B" history-beginning-search-forward-end
fi

# ファイラ: yazi(2026-08-15 に ranger から移行)
#
# ranger は Python 製で、大きなディレクトリでプレビューが同期的に走るぶん待たされる。
# yazi は Rust 製で I/O が非同期。乗り換えの決め手は速度そのものより、
# **ranger 側がもう活発ではない**こと。
#
# 終了時に居たディレクトリへ移動する、というのは ranger-cd と同じ仕掛け。
# yazi 公式が配っているラッパをそのまま使う(--cwd-file で受け取る)。
function y {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  command rm -f -- "$tmp"
}

if (( ZSH_HUMAN )); then
  # Ctrl-O は ranger-cd 時代からの手癖なので割り当てを変えない。
  bindkey -s '^o' 'y^M'

  # zoxide: 訪問したディレクトリを覚えて `z allergy` で飛べるようにする。
  #
  # **`--cmd cd` を付けない。** それは cd を上書きする指定で、この .zshrc が
  # 2026-08-15 にまさにその形(cd を関数で包む)で失敗したところ。エージェントの
  # 実行にも乗ってしまうし、cd の意味を変えると壊れ方が分かりにくくなる。
  # `z` / `zi` という別のコマンドとして足すだけにする。
  if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
  fi
fi

# PATH はファイル冒頭で通してある(mise を探すより前でなければならないため)。

# use starship prompt
# エージェントはプロンプトを描画しないので、初期化する意味が無いどころか、
# precmd フックが毎コマンド走って custom モジュール(mise 呼び出し)のぶん
# 無駄に払うことになる。
if (( ZSH_HUMAN )) && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# NOTE: Docker Desktop likes to append a completions block here. It is already
# handled above (see the fpath line before compinit) — delete the appended copy
# rather than keeping two compinit calls.

# このマシンだけの設定。yadm の追跡外(~/.gitignore)なので、試したことが
# `yadm diff` に出続けない。最後に読むので、上のどれでも上書きできる。
# 環境変数など非対話シェルにも要るものは ~/.zshenv.local のほう。
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
