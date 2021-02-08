" basic settings

" turnoff vi compatibility if set
if !&compatible
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
  if ! isdirectory(s:vimdir . "/backup")
    call system("mkdir " . s:vimdir . "/backup")
  endif
endif

"backup dirs
set backup
set writebackup
set backupdir=$HOME/.vim/backup
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

Plug 'w0ng/vim-hybrid'
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

if has('lua')
Plug 'Valloric/YouCompleteMe', {'do': 'python3 install.py --all'}
Plug 'w0rp/ale'
endif

Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/fzf'
Plug 'ludovicchabant/vim-gutentags'
Plug 'vim-scripts/taglist.vim'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'osyo-manga/vim-anzu'
Plug 'LeafCage/yankround.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'mileszs/ack.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-lastpat'
Plug 'kana/vim-textobj-entire'
Plug 'nelstrom/vim-visual-star-search'
Plug 'editorconfig/editorconfig-vim'
Plug 'pseewald/vim-anyfold'
Plug 'arecarn/vim-fold-cycle'

Plug 'vim-scripts/xml.vim', {'for': ['xml']}
Plug 'mattn/emmet-vim', {'for': ['html', 'css']}
Plug 'ap/vim-css-color'

if has('python')
  Plug 'taketwo/vim-ros'
endif

Plug 'jiangmiao/auto-pairs', {'for': ['lisp', 'scheme', 'clojure']}

" initialize plugin system
call plug#end()
endif

" colorscheme
" use hybrid color scheme
set background=dark

" let g:hybrid_custom_term_colors = 1 " eneble if your terminal using hybrid colorscheme
" let g:hybrid_reduced_contrast = 1 " Remove this line if using the default pallete.
" colorscheme hybrid
colorscheme solarized

" for airline
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1

" setting for ycm
" let g:ycm_global_ycm_extra_conf = '${HOME}/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_auto_trigger = 1
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1

" setting for ale
let g:ale_sign_column_always = 1

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" for UltiSnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<C-k>"
let g:UltiSnipsJumpForwardTrigger="<C-j>"
let g:UltiSnipsJumpBackwardTrigger="<C-b>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" directory for custom snippets
let g:UltiSnipsSnippetsDir="~/.vim/UltiSnips"

" filetypes
autocmd FileType plaintex UltiSnipsAddFiletypes tex.plaintex

" for vim-anzu
" mapping
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)
" clear status
" nmap <Esc><Esc> <Plug>(anzu-clear-search-status)
" statusline
set statusline=%{anzu#search_status()}

" keymaps for yankround
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
xmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)

" emmet setting
" enable just for html/css
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

"let g:user_emmet_mode='n'    "only enable normal mode functions.
"let g:user_emmet_mode='inv'  "enable all functions, which is equal to
let g:user_emmet_mode='a'    "enable all function in all mode.

let g:user_emmet_leader_key='<C-Y>'

" commentary settings
" add comment type for new filetype
" autocmd FileType apache setlocal commentstring=#\ %s

" for vim-anyfold

" activate anyfold by default
augroup anyfold
    autocmd!
    autocmd Filetype * AnyFoldActivate
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
nmap <Tab><Tab> <Plug>(fold-cycle-open)
nmap <S-Tab><S-Tab> <Plug>(fold-cycle-close)

" tagbar setting
nmap <F8> :TagbarToggle<CR>

" jiangmiao/auto-pairs setting

"if exists("g:AutoPairs")
  "default let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', "`":"`", '```':'```', '"""':'"""', "'''":"'''"}
  let g:AutoPairs = {'(':')', '[':']', '{':'}','"':'"'}
"endif

