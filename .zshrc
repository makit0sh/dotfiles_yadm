# alias
alias c="clear"
alias cdd="cd ../"
alias cddd="cd ../../"
alias cdddd="cd ../../../"
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='ls --color=auto'
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

# zinit for plugins
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# For GNU ls (the binaries can be gls, gdircolors, e.g. on OS X when installing the
# # coreutils package from Homebrew; you can also use https://github.com/ogham/exa)
zinit ice atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh" nocompile'!'
zinit light "trapd00r/LS_COLORS"

# Binary release in archive, from GitHub-releases page.
# After automatic unpacking it provides program "fzf".
zinit ice from"gh-r" as"program"
zinit load "junegunn/fzf"

zinit ice src"z.sh"
zinit load "rupa/z"

# Replace zsh default completion selection menu with fzf
zinit light Aloxaf/fzf-tab
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# A glance at the new for-syntax – load all of the above
# plugins with a single command..
zinit for \
    light-mode  "zsh-users/zsh-autosuggestions" \
                "zsh-users/zsh-completions" \
    light-mode  "zdharma/fast-syntax-highlighting" \
                "zdharma/history-search-multi-word" \
    light-mode  "denysdovhan/spaceship-prompt"

# Scripts that are built at install (there's single default make target, "install",
# # and it constructs scripts by `cat'ing a few files). The make'' ice could also be:
# # `make"install PREFIX=$ZPFX"`, if "install" wouldn't be the only, default target.
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras

# use enhancd for cd
zinit ice pick"init.sh"
zinit light "b4b4r07/enhancd"
export ENHANCD_HOOK_AFTER_CD=ls

# fzf shell completion and key-bindings
zinit for \
	"https://github.com/junegunn/fzf/blob/master/shell/completion.zsh" \
	"https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh"

# z search with fzf (require rupa/z)
fzf-z-search() {
    local res=$(z | sort -rn | cut -c 12- | fzf)
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}
zle -N fzf-z-search
bindkey '^f' fzf-z-search

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

