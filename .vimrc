" basic settings

" turnoff vi compatibility if set
"
" 条件が逆だった(2026-08-15 修正)。`if !&compatible` は「既に非互換なら
" 非互換にする」で、**互換モードで始まったときに何もしない**。
"
" 対話起動では vimrc が見つかった時点で Vim が自動的に nocompatible にするので
" 表に出ないが、**`vim -u <file>` は compatible=1 で始まる**。その状態では
" 行継続(行頭の `\`)が使えず、それを使っているプラグインが軒並み
" 「E10: \ の後は / か ? か & でなければなりません」で読み込みに失敗する。
" headless の PlugInstall が動かなかった原因がこれ。
if &compatible
  set nocompatible
endif

" basic settings
" based on github.com/tpope/vim-sensible

if has('autocmd')
  filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

set smartindent
set autoindent
set backspace=indent,eol,start
set complete-=i

set smarttab
set shiftwidth=4
set tabstop=4
set shiftwidth=2
" 2026-08-15: airline を外したので、これを止めていた理由は無くなった。
" 戻すと全角記号の幅の扱いが変わる(端末側の設定と揃える必要がある)ので、
" 必要になったときに外すこと。
"set ambiwidth=double "disabled because airline broke

set nrformats-=octal

if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

set laststatus=2
set ruler
set number
set title
set wildmenu

set scrolloff=1
set sidescrolloff=5
set sidescroll=1
set display+=lastline

set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
set fileformats=unix,dos,mac
scriptencoding utf-8

" visualize unvisible characters
set list
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if v:version > 703 || v:version == 703 && has("patch541")
 set formatoptions+=j " Delete comment character when joining commented lines
endif

if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

if &shell =~ 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/usr/bin/env\ bash
endif

set autoread

if &history < 1000
  set history=1000
endif
if &tabpagemax < 50
  set tabpagemax=50
endif
if !empty(&viminfo)
  set viminfo^=!
endif
set sessionoptions-=options

set hlsearch
if has('extra_search')
  set incsearch
endif
set smartcase

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif

" Load matchit.vim but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

set showmatch
set matchtime=2

set mouse=a

set virtualedit=onemore " let cursor move to one character ahead
set whichwrap=b,s,h,l,<,>,[,]

" disable screen bell
set t_vb=
set novisualbell

set hidden

" filetype settings

au BufNewFile,BufRead *.l setf lisp

" Prepare .vim dir
let s:vimdir = $HOME . "/.vim"
if has("vim_starting")
  if ! isdirectory(s:vimdir)
    call system("mkdir " . s:vimdir)
  endif
  if ! isdirectory(s:vimdir . "/undo")
    call system("mkdir " . s:vimdir . "/undo")
  endif
  if ! isdirectory(s:vimdir . "/swp")
    call system("mkdir " . s:vimdir . "/swp")
  endif
endif

set nobackup
set nowritebackup
set directory=$HOME/.vim/swp
if has('persistent_undo')
    set undodir=$HOME/.vim/undo
    set undofile
endif

" basic keymaps

let mapleader = "\<Space>"

nnoremap tt :tabnew<CR>
nnoremap Y y$
" double tap v to select till line end
vnoremap v $h

" behave naturally in wrapped sentences
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

" change window size by arrows
nnoremap <C-w><Left> <C-w><<CR>
nnoremap <C-w><Right> <C-w>><CR>
nnoremap <C-w><Up> <C-w>-<CR>
nnoremap <C-w><Down> <C-w>+<CR>

" Use <C-L> to clear the highlighting of :set hlsearch
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

inoremap <C-U> <C-G>u<C-U>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" settings regarding cursorline
if has("autocmd")
  " remember last cursor position
  augroup vimrcEx
    au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
          \ exe "normal g`\"" | endif
  augroup END

  "カーソルラインが重かったから調整
  "http://thinca.hatenablog.com/entry/20090530/1243615055
  "2017-11-20
  augroup vimrc-auto-cursorline
    autocmd!
    autocmd CursorMoved,CursorMovedI * call s:auto_cursorline('CursorMoved')
    autocmd CursorHold,CursorHoldI * call s:auto_cursorline('CursorHold')
    autocmd WinEnter * call s:auto_cursorline('WinEnter')
    autocmd WinLeave * call s:auto_cursorline('WinLeave')

    let s:cursorline_lock = 0
    function! s:auto_cursorline(event)
      if a:event ==# 'WinEnter'
        setlocal cursorline
        let s:cursorline_lock = 2
      elseif a:event ==# 'WinLeave'
        setlocal nocursorline
      elseif a:event ==# 'CursorMoved'
        if s:cursorline_lock
          if 1 < s:cursorline_lock
            let s:cursorline_lock = 1
          else
            setlocal nocursorline
            let s:cursorline_lock = 0
          endif
        endif
      elseif a:event ==# 'CursorHold'
        setlocal cursorline
        let s:cursorline_lock = 1
      endif
    endfunction
  augroup END

endif

" quickfix settings
if has("autocmd")
  augroup QuickFixCmd
    autocmd!
    autocmd QuickFixCmdPost *grep* cwindow
  augroup END
endif

" transparent
if !has('gui_running')
    augroup transparent_gui
        autocmd!
        autocmd VimEnter,ColorScheme * highlight Normal ctermbg=none
        autocmd VimEnter,ColorScheme * highlight LineNr ctermbg=none
        autocmd VimEnter,ColorScheme * highlight SignColumn ctermbg=none
        autocmd VimEnter,ColorScheme * highlight VertSplit ctermbg=none
        autocmd VimEnter,ColorScheme * highlight NonText ctermbg=none
    augroup END
endif

" enable tag file
set tags=./tags;

" vim-plug setting
" https://github.com/junegunn/vim-plug

" automatic installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  silent !mkdir ~/.vim/plugged
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" plugins
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
silent! if plug#begin('~/.vim/plugged')

" 2026-08-15: 30個 32MB から12個へ絞った。
"
" 主エディタは VSCode で、vim は「どの箱でも動く道具」として持つ、という
" 前提に切り替えたのが理由。基準は3つ:
"   - 外部バイナリに依存しない(ctags や python3 が要るものは、入っていない
"     箱でただの死荷重になる)
"   - 素の vim に無い機能であること(本体が持つようになったものは本体に任せる)
"   - 新しい箱で PlugInstall が数秒で終わること
"
" 外したもの(理由):
"   ultisnips, vim-snippets   12MB。+python3 が要る。スニペットは VSCode の仕事
"   junegunn/fzf              3.5MB。vimrc に設定が無く、fzf 本体はシェル側にある
"   emmet-vim, xml.vim, vim-css-color
"                             web 専用。VSCode の領分
"   vim-easymotion            2MB。設定が無く、/ と f で足りている
"   vim-airline(+themes)     2.6MB。見た目。ambiwidth=double を壊した当人でもある
"   vim-gutentags, tagbar     ctags バイナリが要る
"   vim-gitgutter             1.5MB。あると便利、無くて困らない
"   vim-fugitive              git CLI がある箱では要らない
"   vim-abolish               使っていない
"   vim-visual-star-search    数行で書けるものに1プラグイン
"   vim-colors-solarized      Vim 9 の同梱 colorscheme で足りる
"   auto-pairs                lisp/scheme/clojure 限定で、その用途が無くなった
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-lastpat'
Plug 'kana/vim-textobj-entire'
Plug 'osyo-manga/vim-anzu'
Plug 'LeafCage/yankround.vim'
Plug 'pseewald/vim-anyfold'
Plug 'arecarn/vim-fold-cycle'

" initialize plugin system
call plug#end()
endif

" editorconfig は Vim 本体の同梱パッケージ(9.0.1799 以降)。
" プラグイン版は 2026-08-15 に外した。
if has('patch-9.0.1799')
  packadd! editorconfig
endif

" colorscheme
" Vim 9 同梱の habamax。solarized プラグインをやめたので本体のものを使う。
" 古い vim には無いので、失敗しても止まらないように silent! を付ける。
set background=dark
silent! colorscheme habamax

" <Plug> への map は、プラグインが無いと**黙って無反応になる**。
" 2026-08-15 に確認したところ、プラグイン未導入の状態では p / P / n / N / * / #
" / <C-p> / <C-n> が全部死んでいた。貼り付けと検索が効かない vim になるので、
" 新しいマシンや素の vimrc を持ち込んだ先で使い物にならない。
"
" 判定は「導入されているか」で行う。**`g:loaded_*` は使えない** —— プラグインの
" 読み込みは vimrc を読み終えた後なので、この時点では必ず未定義になる
" (最初にそれで書いて、実環境でも map が消えた)。
function! s:HasPlug(name) abort
  return isdirectory(expand('~/.vim/plugged/' . a:name))
endfunction

" for vim-anzu(検索位置の表示)
" Vim 8.1.1270 以降は 'shortmess' から S を外すだけで件数が出る。anzu が
" 無いときはそれで代用する。
" statusline は airline をやめたので自前。airline があった頃は
" `set statusline=%{anzu#search_status()}` で足りていた(airline が上書き
" していたため)が、今それをやると**検索状態しか出ない**行になる。
set statusline=%f\ %m%r%h%w%=%{&filetype}\ %l/%L\ %P
if s:HasPlug('vim-anzu')
  nmap n <Plug>(anzu-n-with-echo)
  nmap N <Plug>(anzu-N-with-echo)
  nmap * <Plug>(anzu-star-with-echo)
  nmap # <Plug>(anzu-sharp-with-echo)
  set statusline=%f\ %m%r%h%w\ %{anzu#search_status()}%=%{&filetype}\ %l/%L\ %P
elseif has('patch-8.1.1270')
  set shortmess-=S
endif

" keymaps for yankround(ヤンク履歴)
if s:HasPlug('yankround.vim')
  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap gp <Plug>(yankround-gp)
  xmap gp <Plug>(yankround-gp)
  nmap gP <Plug>(yankround-gP)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
endif

" for vim-anyfold

" activate anyfold by default
"
" `exists(':AnyFoldActivate')` を**発火時に**見る。理由は2つ:
"   - プラグインが無い箱では、ファイルを開くたびに E492 が出ていた
"     (<Plug> の map と同じ形の問題)
"   - PlugInstall の最中は、まだ読み込まれていない状態で FileType が発火する。
"     headless の PlugInstall が最後に exit 1 を返していた原因がこれ
augroup anyfold
    autocmd!
    autocmd Filetype * if exists(':AnyFoldActivate') | AnyFoldActivate | endif
augroup END

" disable anyfold for large files
let g:LargeFile = 1000000 " file is large if size greater than 1MB
autocmd BufReadPre,BufRead * let f=getfsize(expand("<afile>")) | if f > g:LargeFile || f == -2 | call LargeFile() | endif
function LargeFile()
    augroup anyfold
        autocmd! " remove AnyFoldActivate
        autocmd Filetype * setlocal foldmethod=indent " fall back to indent folding
    augroup END
endfunction

let g:anyfold_fold_comments=1
set foldlevel=99

" for fold-cycle
let g:fold_cycle_default_mapping = 0 "disable default mappings
if s:HasPlug('vim-fold-cycle')
  nmap <Tab><Tab> <Plug>(fold-cycle-open)
  nmap <S-Tab><S-Tab> <Plug>(fold-cycle-close)
endif

