# Homebrew の宣言。`brew bundle --global` で流す。
#
# macOS 専用。Linux/WSL 側のパッケージは ~/.config/yadm/bootstrap の apt 節。
# OS を跨いで欲しい CLI は、できるだけ mise(~/.default-tools)に寄せる。

# --- ランタイム管理 ---------------------------------------------------------
brew "mise"      # 言語ランタイム。.tool-versions を読む(asdf の後継)

# --- シェル環境 -------------------------------------------------------------
brew "starship"  # プロンプト
brew "tmux"
brew "coreutils" # GNU 版。BSD 版との差でスクリプトが割れるのを避ける
brew "gawk"
brew "tree"
brew "watch"

# --- エディタ・ナビゲーション -----------------------------------------------
brew "vim"

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

# --- メディア・変換 ---------------------------------------------------------
brew "ffmpeg"
brew "exiftool"
brew "poppler"   # pdftotext。資料の中身を読むのに使う
brew "icoutils"

# --- GUI --------------------------------------------------------------------
cask "caffeine"
cask "maccy"

