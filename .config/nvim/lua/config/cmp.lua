-- ~/.config/nvim/lua/config/cmp.lua

--------------------------------------------------------------------------------
-- nvim-cmp：ONLY enabled in command line; disabled in insert mode ( handled by coc ).
-- <C-p>/<C-n> or <Tab>/<S-Tab> to navigate
-- <up>/<down> for history navigation
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- default ↑ / ↓ - for history navigation -- keep it
-- following mapping is to mapping <UP>/<DOWN> to cmp item selection
--------------------------------------------------------------------------------
-- vim.keymap.set('c', '<Down>', function()
--   if cmp.visible() then vim.schedule( function() cmp.select_next_item() end ) return '' end
--   return t('<Down>')
-- end, { expr = true, silent = true })
-- vim.keymap.set('c', '<Up>', function()
--   if cmp.visible() then vim.schedule( function() cmp.select_prev_item() end ) return '' end
--   return t('<Up>')
-- end, { expr = true, silent = true })

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
