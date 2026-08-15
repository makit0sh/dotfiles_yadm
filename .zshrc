#
# 人間が打っているのか、エージェントが走らせているのか(以降で使うので最初に)
#
# Claude Code はこのファイルを読んだシェルのスナップショット
# (~/.claude/shell-snapshots/、2026-08 の実測で 8,816行・alias 16個)を作り、
# 以後のコマンドをその上で走らせる。つまり **ここに書いた alias と関数は
# エージェントの実行にそのまま乗る**。
#
# **判定は best-effort。** AI_AGENT を付けるのは Claude Code で、VSCode の
# Copilot は付けない。しかも VSCode の統合ターミナルでは「Copilot が動かした」と
# 「人が打っている」を環境変数で区別できない(2026-08 時点。未確認)。
#
# したがって規則はこう:
#   - **外れると壊れるものを、この分岐の下に置かない。** 破壊的な alias
#     (`rm -i` など)や `cd` の上書きは、判定に関係なく撤去する
#   - この分岐に置いてよいのは、**外れても「起動が少し重い」で済むもの**だけ
#
# ZSH_HUMAN=0 を手で作れば、人間のシェルでもエージェント相当に落とせる。
if [[ -n "$AI_AGENT" || -n "$CLAUDE_CODE_ENTRYPOINT" || -n "$CLAUDECODE" ]]; then
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

# version compare
autoload is-at-least

# Set up fzf key bindings and fuzzy completion
# (キーバインドと補完なので人間のときだけ。fzf 自体はコマンドとして常に使える)
if (( ZSH_HUMAN )); then
  if is-at-least 0.48 $(fzf --version); then
    source <(fzf --zsh)
  else
    # for ubuntu version older than 0.48.0
    if [ -e /usr/share/doc/fzf/examples/key-bindings.zsh ] ; then
      source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
    if [ -e /usr/share/doc/fzf/examples/completion.zsh ] ; then
      source /usr/share/doc/fzf/examples/completion.zsh
    fi
  fi
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
if [[ "$(uname)" == "Darwin" ]]; then
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
HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS # Delete an old recorded event if a new event is a duplicate.
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE # Do not record an event starting with a space.

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
  bindkey "^S" history-incremental-search-forward
  bindkey "^[[A" history-beginning-search-backward-end
  bindkey "^[[B" history-beginning-search-forward-end
fi

# Automatically change the directory in bash after closing ranger
#
# This is a bash function for .bashrc to automatically change the directory to
# the last visited one after ranger quits.
# To undo the effect of this function, you can type "cd -" to return to the
# original directory.

function ranger-cd {
    tempfile="$(mktemp -t tmp.XXXXXX)"
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

# This binds Ctrl-O to ranger-cd:
if (( ZSH_HUMAN )); then
  bindkey -s '^o' 'ranger-cd^M'
fi

# add bin in home dir to path
export PATH=~/.local/bin:~/bin:$PATH

# use starship prompt
eval "$(starship init zsh)"

# NOTE: Docker Desktop likes to append a completions block here. It is already
# handled above (see the fpath line before compinit) — delete the appended copy
# rather than keeping two compinit calls.
