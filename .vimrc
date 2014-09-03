set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required

Plugin 'gmarik/Vundle.vim'
set nocompatible              " be iMproved
filetype off                  " required!

" original repos on GitHub
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/syntastic'
Plugin 'bling/vim-airline'
Plugin 'altercation/vim-colors-solarized'
Plugin 'kchmck/vim-coffee-script'
Plugin 'slim-template/vim-slim'
Plugin 'pangloss/vim-javascript'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'ntpeters/vim-better-whitespace'

call vundle#end()             " required
filetype plugin indent on     " required!

" "Turn on syntax highlighting
syntax on

" Solarized
set background=dark
let g:solarized_termtrans=1
let g:solarized_contrast="medium"
let g:solarized_visibility="high"
colorscheme solarized

" Set correct backspace handling
set backspace=2

set hlsearch
set incsearch
set smartcase
set number
set guioptions=aAce
set fileencoding=utf-8
set showcmd

set showmode
set cursorline
hi cursorline guibg=#333333
hi CursorColumn guibg=#333333

" Toggle paste mode remapping with visual feedback with f5
nnoremap <f5> :set invpaste paste?<cr>
set pastetoggle=<f5>
set showmode

" Toggle line numbers pressing f6
nmap <f6> :set number! number?<cr>

" Lock arrows
map <Left> :echo 'Stop using left arrow!'<cr>
map <Right> :echo 'Stop using right arrow!'<cr>
map <Up> :echo 'Stop using up arrow!'<cr>
map <Down> :echo 'Stop using down arrow!'<cr>

" Enable correct indentation
set sw=2 " no of spaces for indenting
set ts=2 " show \t as 2 spaces and treat 2 spaces as \t when deleting, etc..
set expandtab
set softtabstop=2

" Turn on line numbers
:set number

" Enable SCSS support
au BufRead,BufNewFile *.scss set filetype=scss

" Enable autocompletion for CSS files
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
:imap <c-space> <c-x><c-o>

" Enable autocompletion for HTML files
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags

" Enable indention
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent
  " indenting.
filetype plugin indent on
endif

" Enable virtualedit
set virtualedit=all

" Automatic folding for scss files
autocmd BufRead,BufNewFile *.css,*.scss,*.less setlocal foldmethod=marker foldmarker={,}

" Show trailing spaces
set list listchars=trail:·

" Set Control-P plugin
set runtimepath^=~/.vim/bundle/ctrlp.vim
" Remap Control-P
let g:ctrlp_map = '\t'
" Refresh at every call the Control-P cache
let g:ctrlp_use_caching = 0

" Save your swp files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

" viminfo stores the the state of your previous editing session
set viminfo+=n~/.vim/viminfo

if exists("+undofile")
  " undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
  set undofile
endif

" Save your backups to a less annoying place than the current directory.
" If you have .vim-backup in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/backup or . if all else fails.
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup > /dev/null 2>&1
endif
set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.vim/backup/
set backupdir^=./.vim-backup/
set backup

" Custom copy'n'paste
" Copy the current visual selection to ~/.vbuf
" Copy the current line to the buffer file if no visual selection
vmap <C-c> :w! ~/.vbuf<CR>
nmap <C-c> :.w! ~/.vbuf<CR>
" Paste the contents of the buffer file
nmap <C-P> :r ~/.vbuf<CR>

""""""""""""""""""""""""""""""
" airline
""""""""""""""""""""""""""""""
let g:airline_theme             = 'solarized'
let g:airline_enable_branch     = 1
let g:airline_enable_syntastic  = 1
set laststatus=2

" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install (update) bundles
" :BundleSearch(!) foo - search (or refresh cache first) for foo
" :BundleClean(!)      - confirm (or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle commands are not allowed.
