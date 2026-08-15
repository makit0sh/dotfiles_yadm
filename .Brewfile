# Homebrew の宣言。`brew bundle --global` で流す。
#
# 中身は `brew bundle dump` の出力そのものではなく、**`brew leaves` から手で
# 選んだもの**。dump は依存パッケージまで書き出す(148行になった)ので、
# 事故的に入ったものまで新しいマシンへ運んでしまう。ここに書いてあるのは
# 「意図して入れた」ものだけ。
#
# 入れないと決めたもの:
#   asdf   — 2026-08-15 に mise へ移行した。両方を PATH に置かない
#
# macOS 専用。Linux/WSL 側のパッケージは ~/.config/yadm/bootstrap の apt 節。
# OS を跨いで欲しい CLI は、できるだけ mise(~/.default-tools)に寄せる。

# --- ランタイム管理 ---------------------------------------------------------
brew "mise"      # 言語ランタイム。.tool-versions を読む(asdf の後継)

# --- シェル環境 -------------------------------------------------------------
brew "starship"  # プロンプト
brew "tmux"
# fzf は mise 側。apt の fzf が古すぎて(24.04 で 0.44.1)OS ごとに版が割れ、
# .zshrc に古い版用の分岐を生やしていたため。
brew "coreutils" # GNU 版。BSD 版との差でスクリプトが割れるのを避ける
brew "gawk"
brew "tree"
brew "watch"

# --- エディタ・ナビゲーション -----------------------------------------------
brew "vim"
brew "universal-ctags" # vim-gutentags が呼ぶ
# yazi(ファイラ)と zoxide はここではなく mise が持つ。**OS を跨いで同じ版が
# 欲しいものは mise**、というこのリポジトリの層分けに従った結果で、Ubuntu の apt
# には yazi が無く zoxide も古い、という実情とも噛み合う。
# ranger は yazi へ移行したので宣言から外した(2026-08-15)。

# --- git / GitHub -----------------------------------------------------------
brew "git"
brew "gh"
brew "yadm"      # この dotfiles 自身を管理している

# --- 開発 -------------------------------------------------------------------
# **ランタイムとその周辺をここに置かない。** プロジェクトごとに版が違うものを
# グローバルに固定すると、どのプロジェクトにも合わない版が1つ残るだけになる。
# node / pnpm / python は mise(~/.config/mise/config.toml)が持つ。
# poetry は uv に置き換えたので削除。gcc / libomp / pkgconf / zlib も外した —
# 要るのは特定のプロジェクトをビルドするときで、そのときは依存として入る。
# python-tk も外した(tkinter を使わなくなったため)。

# --- ネットワーク・ファイル -------------------------------------------------
brew "curl"
brew "wget"
brew "rclone"

# --- メディア・変換 ---------------------------------------------------------
brew "ffmpeg"
brew "exiftool"
brew "poppler"   # pdftotext。資料の中身を読むのに使う
brew "icoutils"

# --- GUI --------------------------------------------------------------------
cask "claude"
cask "codex"
cask "caffeine"
cask "maccy"
cask "thunderbird"
cask "vnc-viewer"
