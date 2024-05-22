--[[
=============================================================================
     FileName : init.lua
       Author : marslo.jiao@gmail.com
      Created : 2024-01-11 01:33:04
   LastChange : 2024-05-22 01:09:48
=============================================================================
--]]

vim.cmd( 'set runtimepath^=~/.vim runtimepath+=~/.vim/after' )
vim.cmd( 'let &packpath = &runtimepath' )
vim.cmd( 'source ~/.vimrc' )
vim.cmd( 'autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}' )
vim.opt.undodir = vim.fn.expand( '~/.vim/undo' )
-- vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'

require('config/nvim-treesitter')
-- CopilotC-Nvim/CopilotChat.nvim
require("CopilotChat").setup {
  debug = true,
  allow_insecure = true, -- https://github.com/deathbeam/dotfiles/blob/master/nvim/.config/nvim/lua/config/copilot.lua
  show_folds = false,
}
-- require('config.snippets')
-- require('config/lsp')
-- require('undotree').setup()
