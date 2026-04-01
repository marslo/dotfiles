--[[
=============================================================================
     FileName : init.lua
       Author : marslo
      Created : 2024-01-11 01:33:04
   LastChange : 2026-04-01 14:51:11
=============================================================================
--]]

vim.opt.runtimepath:prepend("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")
vim.opt.packpath = vim.opt.runtimepath:get()
vim.cmd( 'source ~/.vimrc' )
vim.opt.undodir = vim.fn.expand( '~/.vim/undo' )

-- highlight on yank
local yank_group = vim.api.nvim_create_augroup('HighlightYank', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'Search', on_visual = true, timeout = 200 })
  end,
})

-- devicons
pcall( require, 'config.devicons' )

-- fzf-lua
pcall( require, 'config.fzf' )

-- treesitter
local ok_ts, err_ts = pcall(require, 'config.nvim-treesitter')
if not ok_ts then
  vim.notify(err_ts, vim.log.levels.WARN)
end

-- nvim-cmp
pcall( require, 'config.cmp' )

-- copilot.lua + CopilotChat + LuaSnip integration
pcall( require, 'config.copilot' )

-- asynchronous/lazy loading
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- tiktoken_core -- lua/tiktoken_core.[dylib|so|dll] - for CopilotChat
    pcall( require, 'tiktoken_core' )
  end
})

-- rainbow-delimiters
-- local ok_rb, _ = pcall( require, 'config.rainbow' )
-- if not ok_rb then
--   vim.notify( 'rainbow-delimiters config not found', vim.log.levels.WARN )
-- end

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
