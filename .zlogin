# .zlogin — ログインシェルが最後に読む。**対話でなくても読まれる**。
#
# ここにあるのは PATH の順序を戻す3行だけ。なぜ .zshenv でも .zshrc でもなく
# ここなのか:
#
#   zshenv → (/etc/zprofile) → zprofile → [zshrc] → zlogin
#
# `.zshenv` は shims を先頭に置くが、その**後**に /etc/zprofile の path_helper が
# PATH を組み直して /etc/paths を前に出し、続く ~/.zprofile の `brew shellenv` が
# /opt/homebrew/bin をさらに前に出す。`.zshrc` はこれを戻しているが、**zsh は
# 対話シェルでしか .zshrc を読まない**。
#
# 残るのが「ログイン かつ 非対話」で、そこには順序を戻す担当がいなかった。
# 2026-08-28 に allergy_search で実際に踏んだ: エージェントのシェルがまさに
# その組み合わせで、`node` は Homebrew の 26.7.0(プロジェクトは 24)、
# `openssl` は /usr/bin の LibreSSL(Homebrew の OpenSSL 3 が要る)を掴み、
# `pnpm test` がクリーンな作業ツリーでも落ちた。**人間の端末では再現しない** ——
# そちらは .zshrc が直しているので。
#
# .zprofile ではなくここなのは、.zprofile が yadm 管理外の1行(brew shellenv)で、
# ホストごとに中身が違うため。ここなら追跡下に置ける。
typeset -U path PATH
path=(~/.local/bin ~/bin $path)
[[ -d ~/.local/share/mise/shims ]] && path=(~/.local/share/mise/shims $path)
export PATH
