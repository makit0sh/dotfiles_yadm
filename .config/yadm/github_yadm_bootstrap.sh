#!/usr/bin/env bash
#
# 新しいマシンでの入口。yadm が入っていない状態から始められる。
#
#   bash -c "$(curl -fsSL https://git.io/JO0b6)"
#
# 短縮 URL はこのファイル自身の raw を指しているので、ここを変えれば入口も変わる。
#
# 仕事のマシンなら class を渡す:
#   YADM_CLASS=work bash -c "$(curl -fsSL https://git.io/JO0b6)"

set -euo pipefail

class="${YADM_CLASS:-personal}"

if ! command -v yadm >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install yadm
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y yadm
  else
    # パッケージ manager が無い環境向けの最後の手段。
    mkdir -p ~/bin
    git clone https://github.com/TheLocehiliosan/yadm.git ~/.yadm-project
    ln -sf ~/.yadm-project/yadm ~/bin/yadm
    export PATH=~/bin:$PATH
  fi
fi

yadm clone https://github.com/makit0sh/dotfiles_yadm

# class は clone 直後、bootstrap より先に決める。**飛ばすと `##class.*` の
# ファイルが展開されず**、.gitconfig も ~/.claude/CLAUDE.md も生成されない。
# 2026-08-15 に class 運用を入れたとき、この経路だけ追従できていなかった。
yadm config local.class "$class"
yadm alt

yadm bootstrap

cat <<EOF

class は "$class" にした。違うなら:
  yadm config local.class work && yadm alt

残り: 新しいシェルを開く / gh auth login / claude のログイン
EOF
