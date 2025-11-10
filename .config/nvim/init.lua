--[[
=============================================================================
     FileName : init.lua
       Author : marslo.jiao@gmail.com
      Created : 2024-01-11 01:33:04
   LastChange : 2025-11-10 15:39:30
=============================================================================
--]]

vim.cmd( 'set runtimepath^=~/.vim runtimepath+=~/.vim/after' )
vim.cmd( 'let &packpath = &runtimepath' )
vim.cmd( 'source ~/.vimrc' )

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'Search', on_visual = true })
  end,
})

vim.opt.undodir = vim.fn.expand( '~/.vim/undo' )

-- devicons
pcall( require, 'config/devicons' )

-- fzf-lua
pcall( require, 'config/fzf' )

-- treesitter
pcall( require, 'config/nvim-treesitter' )

-- copilot.lua + CopilotChat + LuaSnip integration
pcall( require, 'config/copilot' )

-- nvim-cmp
pcall( require, 'config/cmp' )

-- tiktoken_core -- lua/tiktoken_core.[dylib|so|dll]
pcall( require, 'tiktoken_core' )

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
