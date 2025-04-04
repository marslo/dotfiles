runtime macros/matchit.vim
runtime defaults.vim
let performance_mode = 1

filetype off
call plug#begin( '~/.vim/plugged_verify' )
Plug "junegunn/vim-plug"
Plug 'tpope/vim-pathogen'
call plug#end()
call pathogen#infect( '~/.vim/plugged_verify/{}' )
call pathogen#helptags()

filetype plugin indent on
syntax enable on
