#!/bin/bash

if ! command -v yadm &> /dev/null
then
  # debian base system
  if type apt > /dev/null 2>&1; then
    sudo apt update
    sudo apt install -y yadm
  else
    mkdir -p ~/bin
    git clone https://github.com/TheLocehiliosan/yadm.git ~/.yadm-project
    ln -s ~/.yadm-project/yadm ~/bin/yadm
    export PATH=~/bin:$PATH
  fi
fi

yadm clone https://github.com/makit0sh/dotfiles_yadm
