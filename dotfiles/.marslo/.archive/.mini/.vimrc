let &runtimepath=printf('%s/vimfiles,%s,%s/vimfiles/after', $VIM, $VIMRUNTIME, $VIM)
let s:portable = expand('<sfile>:p:h')
let &runtimepath=printf('%s/.vim,%s/.vim,%s/.vim/after', s:portable, &runtimepath, s:portable)

set nocompatible
set clipboard=unnamedplus
set number
set tabstop=2
set softtabstop=2
set shiftwidth=2
set nobackup noswapfile nowritebackup
set smarttab expandtab
set incsearch hlsearch ignorecase smartcase
set autoindent smartindent
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
set go+=a
set modifiable

syntax enable on
filetype plugin indent on
autocmd! bufwritepost $HOME/.marslo/.vimrc source %
nmap <leader>v :e $HOME/.marslo/.vimrc<CR>

if 'xterm-256color' == $TERM
  set t_Co=256
  colorscheme marslo256
endif

noremap <F1> <ESC>
inoremap <F1> <ESC>a
inoremap <C-a> <ESC>I
inoremap <C-e> <ESC>A
map <C-a> <ESC>^
map <C-e> <ESC>$
inoremap <M-f> <ESC><Space>Wi
inoremap <M-b> <Esc>Bi
inoremap <M-d> <ESC>cW

nmap zhh :%s/^\s\+//<CR>
nmap zmm :g/^/ s//\=line('.').' '/<CR>
nmap zws :g/^\s*$/d<CR>

set laststatus=2
set statusline=%m%r
set statusline+=%F\ \ %y,%{&fileformat}
set statusline+=%=
set statusline+=\ \ %-{strftime(\"%H:%M\ %d/%m/%Y\")}
set statusline+=\ \ %b[A],0x%B
set statusline+=\ \ %c%V,%l/%L
set statusline+=\ \ %p%%\

set list listchars=tab:\ \ ,trail:.,extends:>,precedes:<,nbsp:.
