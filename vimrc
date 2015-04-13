set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

Plugin 'gmarik/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Bundle 'scrooloose/syntastic'
Bundle 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'scrooloose/nerdtree'
Bundle 'kien/ctrlp.vim'
Bundle 'mattn/emmet-vim'
Bundle 'wavded/vim-stylus'

let g:Powerline_symbols = 'fancy'

filetype off
filetype plugin indent on
syntax on

set autoindent
set smartindent
set autoread
set background=dark
set backspace=indent,eol,start
set cmdheight=1
set lazyredraw	
set linebreak
set more	
set noautowrite	
set noerrorbells	
set noexpandtab
set nowrap
set number	
set showmode	
set showcmd	
set nocompatible	
set smarttab	
set shiftwidth=4
set shell=bash
set splitright	
set splitbelow	
set tabstop=4	
set visualbell
set wildmenu	
set encoding=utf-8
set termencoding=utf-8
set laststatus=2
set t_Co=256
set mouse=a

colorscheme gruvbox

" map <Leader> to ,
let mapleader = ","

" Leader commands
nmap <Leader>r :e app/Http/routes.php<cr>

" toggle NERDTree with F2
silent! nmap <F2> :NERDTreeToggle<cr>

" expand emmet with <Tab>
" imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

" switch buffers with Ctrl+{h,j,k,l}
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" quicker splits
nmap vs :vsplit<cr>
nmap sp :split<cr>

" highlight the search term
highlight Search cterm=underline

" save buffers with Ctrl+s
nmap  <C-s> :w<cr>
