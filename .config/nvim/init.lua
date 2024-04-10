vim.cmd( 'set runtimepath^=~/.vim runtimepath+=~/.vim/after' )
vim.cmd( 'let &packpath = &runtimepath' )
vim.cmd( 'source ~/.vimrc' )
vim.cmd( 'autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}' )
vim.opt.undodir = vim.fn.expand( '~/.vim/undo' )
-- vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'

-- require('config/nvim-treesitter')
-- require('config/lsp')
-- require('undotree').setup()
