syntax on

set autoindent smartindent	" auto/smart indent
set autoread	" watch for file changes
set background=dark
set backspace=indent,eol,start
set cmdheight=2	" command line two lines high
set ff=unix
set fileformats=unix
set hidden
set history=300
set lazyredraw	" don't redraw when don't have to
set linebreak
set more	" use more prompt
set noautowrite	" don't automagically write on :next
set noerrorbells	" No error bells please
set noexpandtab
set nowrap
set number	" line numbers
set showmode	" show current editing mode
set showcmd	" show current command related information
set nocompatible	" vim, not vi
set smarttab	" tab and backspace are smart
set shiftwidth=4
set shell=bash
set scrolloff=10	" keep at least 5 lines above/below
set sidescrolloff=5	" keep at least 5 lines left/right
set splitright	" vsplit to the right
set splitbelow	" split below
set tabstop=4	" 6 spaces
set undolevels=1000	" 1000 undos
set updatecount=100	" switch every 100 chars
set visualbell
set wildmenu	" menu has tab completion

filetype on	" Enable filetype detection
filetype indent on	" Enable filetype-specific indenting
filetype plugin on	" Enable filetype-specific plugins

:imap jj <Esc>	" Leave insert mode with 
:nmap <C-k> I//<Esc>
