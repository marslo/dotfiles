--[[
=============================================================================
     FileName : init.lua
       Author : marslo.jiao@gmail.com
      Created : 2024-01-11 01:33:04
   LastChange : 2025-11-10 15:06:22
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

-- fzf-lua & devicons
pcall( function()
  require('nvim-web-devicons').setup({
    color_icons = true,
    default = true,
    strict = true,
    variant = 'dark',
    override_by_operating_system = {
      ['apple'] = {
        icon = '',
        color = '#A2AAAD',
        cterm_color = '248',
        name = 'Apple',
      },
    },
  })
end )
pcall( function() require('fzf-lua').register_ui_select() end )

-- treesitter
pcall( require, 'config/nvim-treesitter' )

-- tiktoken_core
pcall( require, 'tiktoken_core' )

-- copilot.lua + CopilotChat + nvim-cmp + LuaSnip integration
pcall( require, 'config/copilot' )

--------------------------------------------------------------------------------
-- nvim-cmp：ONLY enabled in command line; disabled in insert mode ( handled by coc ).
-- <C-p>/<C-n> or <Tab>/<S-Tab> to navigate
-- <up>/<down> for history navigation
--------------------------------------------------------------------------------
do
  local ok, cmp = pcall( require, 'cmp' )
  if not ok then return end

  cmp.setup({
    enabled = function()
      -- ONLY enabled in command-line mode; returns false in insert mode.
      return vim.api.nvim_get_mode().mode == 'c'
    end,
    mapping = {},   -- NOT set any mappings for the insert mode to avoid overwriting Up/Down/CR/Tab.
    sources = {},   -- NOT require any source in insert status
  })

  -- ':' command line: path + command completion
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
      { { name = 'path' } },
      { { name = 'cmdline', option = { ignore_cmds = {
            'w','wa','wq','x','xa','q','qa','qall','write','wall','wq','xit','xall','quit'
      } } } }
    ),
  })

  -- search using '/' and '?' for the word "buffer".
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
  })

  -- keymap for navigation in command line --
  local function t(keys) return vim.api.nvim_replace_termcodes( keys, true, true, true ) end
  -- -- ↑ / ↓ - for history navigation
  -- vim.keymap.set('c', '<Down>', function()
  --   if cmp.visible() then vim.schedule( function() cmp.select_next_item() end ) return '' end
  --   return t('<Down>')
  -- end, { expr = true, silent = true })
  -- vim.keymap.set('c', '<Up>', function()
  --   if cmp.visible() then vim.schedule( function() cmp.select_prev_item() end ) return '' end
  --   return t('<Up>')
  -- end, { expr = true, silent = true })

end

-- vim:tabstop=4:softtabstop=4:shiftwidth=4:expandtab:filetype=lua:
