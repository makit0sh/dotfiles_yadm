#!/bin/sh

if ! command -v COMMAND &> /dev/null
  mkdir -p ~/bin
  git clone https://github.com/TheLocehiliosan/yadm.git ~/.yadm-project
  ln -s ~/.yadm-project/yadm ~/bin/yadm
  export PATH=~/bin:$PATH
fi

yadm clone https://github.com/makit0sh/dotfiles_yadm

