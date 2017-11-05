scriptencoding utf-8
set encoding=utf-8

set nocompatible
filetype off


""""""""""""""""""""""""""""""
" Vim-Plug
""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'
Plug 'kien/ctrlp.vim'
Plug 'bling/vim-airline'
Plug 'slim-template/vim-slim'
Plug 'pangloss/vim-javascript'
Plug 'mustache/vim-mustache-handlebars'
Plug 'ntpeters/vim-better-whitespace'
Plug 'heartsentwined/vim-emblem'
Plug 'elixir-lang/vim-elixir'
Plug 'sjl/vitality.vim'
Plug 'vim-airline/vim-airline-themes'
Plug 'janko-m/vim-test'
Plug 'w0rp/ale'
Plug 'jaawerth/nrun.vim'
Plug 'kassio/neoterm'
Plug 'easymotion/vim-easymotion'
Plug 'Shougo/deoplete.nvim'
Plug 'mileszs/ack.vim'
Plug 'Raimondi/delimitMate'

" Themes
Plug 'altercation/vim-colors-solarized'
Plug 'trevordmiller/nova-vim'

" Markdown support
Plug 'plasticboy/vim-markdown'

" Php development
Plug 'stanAngeloff/php.vim'

" JS development
Plug 'ternjs/tern_for_vim'
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'leafgarland/typescript-vim'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'Quramy/tsuquyomi'

" Clojure development
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fireplace'
Plug 'losingkeys/vim-niji'
Plug 'sjl/tslime.vim'
Plug 'https://github.com/guns/vim-clojure-static.git'
Plug 'https://github.com/kien/rainbow_parentheses.vim.git'
Plug 'https://github.com/vim-scripts/paredit.vim.git'
Plug 'https://github.com/guns/vim-clojure-highlight.git'

" Api Blueprint support
Plug 'kylef/apiblueprint.vim'

" Purescript
Plug 'https://github.com/raichoo/purescript-vim.git'

" Reason
Plug 'reasonml-editor/vim-reason'

call plug#end()

filetype plugin indent on


""""""""""""""""""""""""""""""
" General configuration
""""""""""""""""""""""""""""""
syntax on                 " Turn on syntax highlighting
set backspace=2           " Set correct backspace handling

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

:let mapleader = "§"      " Remap leader key

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

" Custom copy'n'paste
" Copy the current visual selection to ~/.vbuf
" Copy the current line to the buffer file if no visual selection
vmap <C-c> :w! ~/.vbuf<CR>
nmap <C-c> :.w! ~/.vbuf<CR>
" Paste the contents of the buffer file
nmap <C-P> :r ~/.vbuf<CR>

" Enable correct indentation
set sw=2 " no of spaces for indenting
set ts=2 " show \t as 2 spaces and treat 2 spaces as \t when deleting, etc..
set expandtab
set softtabstop=2

" Turn on line numbers
:set number
:set numberwidth=3

" Enable indention
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent
  " indenting.
filetype plugin indent on
endif

set virtualedit=all       " Enable virtualedit

" Show trailing spaces
set list listchars=trail:·

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


""""""""""""""""""""""""""""""
" Solarized
""""""""""""""""""""""""""""""
set background=dark
let g:solarized_termtrans=1
let g:solarized_contrast="medium"
let g:solarized_visibility="high"
colorscheme solarized


""""""""""""""""""""""""""""""
" Ack.vim
""""""""""""""""""""""""""""""
if executable('ag')
  let g:ackprg = 'ag --vimgrep'     " Use ag instead of ack
endif

" Remap the search in all files command to <leader>a
nmap <leader>f :Ack! 

" Remap the search in all files command to <leader>f
nmap <leader>ff :AckFile! 


""""""""""""""""""""""""""""""
" Deoplete & Neopairs & Tern
""""""""""""""""""""""""""""""
let g:tern_show_argument_hints="on_hold"                                    " Tern configuration
let g:deoplete#enable_at_startup = 1                                        " Enable deoplete
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif    " Autoclose the top panel when completion is selected

if !exists('g:deoplete#omni#input_patterns')
  let g:deoplete#omni#input_patterns = {}
endif

autocmd FileType javascript setlocal omnifunc=tern#Complete                 " Autocomplete with tern

let g:deoplete#auto_complete_delay = 25                 " Delay the display of the complete
let g:deoplete#auto_completion_start_length = 1         " Start the completion at the first char inserted
let g:deoplete#sources#ternjs#types = 1                 " Include the types of the completions in the result data.
let g:deoplete#sources#ternjs#depths = 1                " Include the distance between the completions and the origin position in the result data.
let g:deoplete#sources#ternjs#docs = 1                  " Include documentation strings in the result data.
let g:deoplete#sources#ternjs#filter = 0                " When on, only completions that match the current word will be returned. Turn this off to get all results.
let g:deoplete#sources#ternjs#case_insensitive = 1      " Use a case-insensitive compare between the current word and potential completions.
let g:deoplete#sources#ternjs#guess = 0                 " When no completions are found, Tern will not use some heuristics to try and return some properties anyway.
let g:deoplete#sources#ternjs#sort = 0                  " The result set will not be sorted.
let g:deoplete#sources#ternjs#expand_word_forward = 0   " Only the text before the given position is considered part of the word.
let g:deoplete#sources#ternjs#omit_object_prototype = 0 " Do not ignore the properties of Object.prototype unless they have been spelled out by at least to characters.
let g:deoplete#sources#ternjs#include_keywords = 1      " Include JavaScript keywords when completing something that is not a property.
let g:deoplete#sources#ternjs#in_literal = 0            " Completions should not be returned when inside a literal.
let g:deoplete#sources#ternjs#filetypes = [
  \ 'jsx',
  \ 'javascript.jsx',
  \ 'vue',
  \ ]
set splitbelow                                          " Put the preview window at the bottom

""""""""""""""""""""""""""""""
" Airline
""""""""""""""""""""""""""""""
let g:airline_powerline_fonts               = 1
let g:airline_theme                         = 'solarized'
let g:airline#extensions#branch#enabled     = 1
let g:airline#extensions#naomake#enabled    = 1
set laststatus=2

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"


""""""""""""""""""""""""""""""
" Ctrl-P
""""""""""""""""""""""""""""""
set runtimepath^=~/.vim/bundle/ctrlp.vim                    " Remap Control-P
let g:ctrlp_map = '§t'                                      " Refresh at every call the Control-P cache
let g:ctrlp_use_caching = 0                                 " Exclude common directories from ctrlp
let g:ctrlp_custom_ignore = '\v[\/](node_modules|dist|tmp|deps|_build|build|out|coverage)$'


""""""""""""""""""""""""""""""
" Ale
""""""""""""""""""""""""""""""
let g:airline#extensions#ale#enabled = 1                    " Airline
let g:ale_javascript_eslint_options = '-c .eslintrc.yml'    " ESLint

let g:ale_linters = { 'javascript': ['flow', 'eslint'] }    " Limit linters used for JavaScript.
highlight clear ALEErrorSign                                " otherwise uses error bg color (typically red)
highlight clear ALEWarningSign                              " otherwise uses error bg color (typically red)
let g:ale_sign_error = '>>'                                 " Error sign
let g:ale_sign_warning = '??'                               " Warning sign
let g:ale_set_highlights = 0                                " Disable underline for errors
let g:ale_sign_column_always = 1                            " Always display the left column with Ale messages (SignColumn)
let g:ale_statusline_format = ['X %d', '? %d', '']          " Format of the status line
let g:ale_echo_msg_format = '%linter% says %s'              " %linter% is linter name, %s is the error or warning message

" Setup colors
highlight clear SignColumn
highlight ALEErrorSign guibg=yellow guifg=red ctermbg=NONE ctermfg=red
highlight ALEWarningSign guibg=yellow guifg=red ctermbg=NONE ctermfg=yellow

" Map keys to navigate between lines with errors and warnings.
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>


""""""""""""""""""""""""""""""
" Rainbow Parenthesis
""""""""""""""""""""""""""""""
let g:niji_dark_colours = [
    \ [ '81', '#5fd7ff'],
    \ [ '99', '#875fff'],
    \ [ '1',  '#dc322f'],
    \ [ '76', '#5fd700'],
    \ [ '3',  '#b58900'],
    \ [ '2',  '#859900'],
    \ [ '6',  '#2aa198'],
    \ [ '4',  '#268bd2'],
    \ ]

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
let g:rbpt_colorpairs = [
  \ [ '13', '#6c71c4'],
  \ [ '5',  '#d33682'],
  \ [ '1',  '#dc322f'],
  \ [ '9',  '#cb4b16'],
  \ [ '3',  '#b58900'],
  \ [ '2',  '#859900'],
  \ [ '6',  '#2aa198'],
  \ [ '4',  '#268bd2'],
  \ ]


""""""""""""""""""""""""""""""
" tslime
""""""""""""""""""""""""""""""
let g:tslime_ensure_trailing_newlines = 1
let g:tslime_normal_mapping = '§e'
let g:tslime_visual_mapping = '§e'
let g:tslime_vars_mapping = '§E'
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
vmap <leader>e <Plug>SendSelectionToTmux
nmap <leader>e <Plug>NormalModeSendToTmux
nmap <leader>E <Plug>SetTmuxVars


""""""""""""""""""""""""""""""
" Paredit
""""""""""""""""""""""""""""""
let g:paredit_mode = 1


""""""""""""""""""""""""""""""
" Neoterm
""""""""""""""""""""""""""""""
let g:neoterm_autoscroll = 1        " Autoscroll neoterm to the bottom
let g:neoterm_keep_term_open = 0    " Keep neoterm open and hides instead of closing it between commands
nnoremap <silent> <leader>q :Tclose<cr>


""""""""""""""""""""""""""""""
" Vim-Test
""""""""""""""""""""""""""""""
let test#ruby#rspec#executable = "!bundle exec rspec"
let test#ruby#rspec#options = '-fd'
let test#strategy = "neoterm"

let test#javascript#mocha#executable = "NODE_PATH=./src NODE_ENV=test ./node_modules/mocha/bin/mocha"
let test#javascript#mocha#file_pattern = '_spec\.js'
let test#javascript#mocha#options = {
  \ 'file':    '--compilers js:babel-core/register --require babel-polyfill --reporter dot',
  \ 'suite':   '--compilers js:babel-core/register --require babel-polyfill --reporter dot test/unit/**/*.js test/integration/**/*.js',
  \}

let test#javascript#jest#executable = "node_modules/jest/bin/jest.js --config .jest.json --verbose --runInBand"
let test#javascript#jest#file_pattern = '\.spec\.js'

nmap <silent> <leader>p :TestFile<CR>
nmap <silent> <leader>a :TestSuite<CR>


""""""""""""""""""""""""""""""
" Vitality
""""""""""""""""""""""""""""""
let g:vitality_fix_cursor = 1
let g:vitality_fix_focus = 1
let g:vitality_always_assume_iterm = 1


""""""""""""""""""""""""""""""
" Supertab
""""""""""""""""""""""""""""""
let g:SuperTabDefaultCompletionType = "context"


""""""""""""""""""""""""""""""
" Custom clojure setup
""""""""""""""""""""""""""""""
au BufReadPost build.boot set syntax=clojure                                                        " Forcing clojure build.boot file syntax highlighting
autocmd filetype lisp,scheme,art setlocal equalprg=scmindent.rkt                                    " Indentation fix for Lisp and Scheme
command VimConnect execute 'Piggieback (adzerk.boot-cljs-repl/repl-env :ip "edev" :ws-host "edev")' " Allow vim to send commands to the browser in Clojurescript


""""""""""""""""""""""""""""""
" Custom Javascript setup
""""""""""""""""""""""""""""""
let g:jsx_ext_required = 0    " Allow JSX in normal JS files


""""""""""""""""""""""""""""""
" Custom Python setup
""""""""""""""""""""""""""""""
let g:python3_host_prog = '/usr/local/bin/python3'  " Python 3 support


""""""""""""""""""""""""""""""
" Custom HTML setup
""""""""""""""""""""""""""""""
" Enable autocompletion for HTML files
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags


""""""""""""""""""""""""""""""
" Custom CSS-SCSS setup
""""""""""""""""""""""""""""""
au BufRead,BufNewFile *.scss set filetype=scss

autocmd FileType css set omnifunc=csscomplete#CompleteCSS                                 " Enable autocompletion for CSS files
:imap <c-space> <c-x><c-o>
autocmd BufRead,BufNewFile *.css,*.scss,*.less setlocal foldmethod=marker foldmarker={,}  " Automatic folding for CSS-SCSS files
