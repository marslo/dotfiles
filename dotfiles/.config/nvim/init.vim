autocmd Filetype Groovy set filetype=groovy syntax=groovy
autocmd Filetype Groovy setf groovy
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
au TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}

lua require("config/nvim-treesitter.lua")
