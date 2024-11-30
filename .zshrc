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
alias mv="mv -i"
alias rm='rm -i'
alias vi='vim'
# auto ls after cd
function cd(){
  builtin cd $@ && ls;
}

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

# vi like keybinds
bindkey -v
export KEYTIMEOUT=1 # kill the lag
bindkey "^W" backward-kill-word    # vi-backward-kill-word
bindkey "^H" backward-delete-char  # vi-backward-delete-char
bindkey "^U" kill-line             # vi-kill-line
bindkey "^?" backward-delete-char  # vi-backward-delete-char

# changing directories
setopt AUTO_CD
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

# completion
autoload -Uz compinit
compinit
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 補完で大文字小文字を区別しない。
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

# history search 
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
# bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# version compare
autoload is-at-least

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
bindkey -s '^o' 'ranger-cd^M'

# Set up fzf key bindings and fuzzy completion
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

##? Clone a plugin, identify its init file, source it, and add it to your fpath.
# borrowed from https://github.com/mattmc3/zsh_unplugged
function plugin-load {
  local repo plugdir initfile initfiles=()
  : ${ZPLUGINDIR:=${ZDOTDIR:-~/.config/zsh}/plugins}
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

#
# plugins from github
#
repos=(
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions
  zsh-users/zsh-syntax-highlighting
  Aloxaf/fzf-tab
  trapd00r/LS_COLORS
)

plugin-load $repos

if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# add bin in home dir to path
export PATH=~/.local/bin:$PATH
export PATH=~/bin:$PATH

# use starship prompt
eval "$(starship init zsh)"

