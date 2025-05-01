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
-- vim.cmd( 'autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=true}' )
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Search", on_visual = true })
  end,
})
vim.opt.undodir = vim.fn.expand( '~/.vim/undo' )
-- vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'

require('config/nvim-treesitter')
-- CopilotC-Nvim/CopilotChat.nvim
require("CopilotChat").setup {
  debug = true,
  allow_insecure = true, -- https://github.com/deathbeam/dotfiles/blob/master/nvim/.config/nvim/lua/config/copilot.lua
  show_folds = false
}

-- require("ibl").setup()
-- require('config.snippets')
-- require('config/lsp')
-- require('undotree').setup()

--[[
-- coc-symbol-line --
function _G.symbol_line()
  local curwin = vim.g.statusline_winid or 0
  local curbuf = vim.api.nvim_win_get_buf(curwin)
  local ok, line = pcall(vim.api.nvim_buf_get_var, curbuf, 'coc_symbol_line')
  return ok and line or ''
end
vim.o.tabline    = '%!v:lua.symbol_line()'
vim.o.statusline = '%!v:lua.symbol_line()'
vim.o.winbar     = '%!v:lua.symbol_line()'
--]]
