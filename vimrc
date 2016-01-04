filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

Plugin 'gmarik/Vundle.vim'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'wavded/vim-stylus'
Plugin 'gerw/vim-latex-suite'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/syntastic'
Plugin 'joshdick/onedark.vim'

filetype plugin indent on

" Fix the tabline
hi TabLineFill ctermfg=Red   ctermbg=Black
hi Tabline     ctermfg=White ctermbg=Gray
hi TablineSel  ctermfg=White ctermbg=Black

" Comma is the leader
let mapleader = ","

" Use ; for : commands
nnoremap ; :

" Switch buffers with <Ctrl-(h|j|k|l)>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Misc leader commands
nnoremap <Leader>ss :split<cr>
nnoremap <Leader>sv :vsplit<cr>
nnoremap <Leader>v 	:tabfind $MYVIMRC<cr>
nnoremap <Leader>t 	:tabedit .<cr>
nnoremap <Leader>f 	:NERDTreeToggle<cr>
nnoremap <Leader>gg :GitGutterToggle<cr>
nnoremap <Leader>rc :source ~/.vimrc<cr>

" Airline
let g:airline_powerline_fonts = 1

" Ctrl+P
" let g:ctrlp_custom_ignore = '(node_modules|bower_components|.sass-cache|.git|.log)'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](node_modules|bower_components|.sass-cache|.git)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': '',
  \ }

" Emmet
" let g:user_emmet_expandabbr_key = '<Tab>'
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" NERDTree
let NERDTreeIgnore = ['\.aux$', '\~$']

" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Colors
syntax on
colorscheme onedark

" Indentation & Whitespace
set autoindent
set smartindent
set noexpandtab
set tabstop=4
set shiftwidth=4
set listchars+=space:\ ,tab:\ \ ,trail:·
set list

" Folding
set foldmethod=indent
set foldlevelstart=4

" Terminal related
set shell=bash
set laststatus=2
set wildmenu
set t_Co=256
set termencoding=utf-8
set mouse=a
set nocursorline

" Misc
set scrolloff=10
set autoread
set backspace=indent,eol,start
set lazyredraw	
set linebreak
set more
set noautowrite
set noerrorbells
set showcmd
set nocompatible

" Layout
set splitright
set splitbelow
set cmdheight=1
set visualbell
set nowrap
set number
set relativenumber
set noshowmode
