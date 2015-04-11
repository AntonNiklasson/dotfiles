set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()
Plugin 'gmarik/Vundle.vim'

Plugin 'tpope/vim-fugitive'
Bundle 'scrooloose/syntastic'
Bundle 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'scrooloose/nerdtree'
Bundle 'kien/ctrlp.vim'

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
set guifont=Inconsolata\ for\ Powerline:h15

let g:Powerline_symbols = 'fancy'

colorscheme gruvbox

:imap jj 		<Esc>

:nmap <C-k> :NERDTreeToggle<cr>
