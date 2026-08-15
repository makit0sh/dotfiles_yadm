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

tap "supabase/tap"

# --- ランタイム管理 ---------------------------------------------------------
brew "mise"      # 言語ランタイム。.tool-versions を読む(asdf の後継)

# --- シェル環境 -------------------------------------------------------------
brew "starship"  # プロンプト
brew "fzf"       # 曖昧検索。zshrc の key-bindings と fzf-tab が依存
brew "tmux"
brew "coreutils" # GNU 版。BSD 版との差でスクリプトが割れるのを避ける
brew "gawk"
brew "tree"
brew "watch"

# --- エディタ・ナビゲーション -----------------------------------------------
brew "vim"
brew "universal-ctags" # vim-gutentags が呼ぶ
brew "ranger"          # ファイラ。yazi への置き換えを検討中(惰性で使っている)

# --- git / GitHub -----------------------------------------------------------
brew "git"
brew "gh"
brew "yadm"      # この dotfiles 自身を管理している

# --- 開発 -------------------------------------------------------------------
brew "node"      # mise が per-project の node を持つが、素の node も残す
brew "pnpm"
brew "poetry"
brew "gcc"
brew "libomp"
brew "pkgconf"
brew "zlib"
brew "python-tk@3.13"

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
