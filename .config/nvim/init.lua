--[[
=============================================================================
     FileName : init.lua
       Author : marslo.jiao@gmail.com
      Created : 2024-01-11 01:33:04
   LastChange : 2025-11-04 01:56:31
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

-- treesitter
pcall(require, 'config/nvim-treesitter')

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

--------------------------------------------------------------------------------
-- copilot.lua + CopilotChat + nvim-cmp + LuaSnip integration
--------------------------------------------------------------------------------
-- 0) remove default <Tab>/<S-Tab> in Neovim 0.11 ( insert & select mode )
for _, mode in ipairs({ 'i', 's' }) do
  pcall( vim.keymap.del, mode, '<Tab>'   )
  pcall( vim.keymap.del, mode, '<S-Tab>' )
end

local function t(keys) return vim.api.nvim_replace_termcodes( keys, true, true, true ) end

-- 1) Copilot inline
local ok_copilot, copilot = pcall( require, 'copilot' )
if ok_copilot then
  copilot.setup({
    -- copilot_node_command = "/opt/homebrew/bin/node",
    server_opts_overrides = { strict_ssl = false },

    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept       = false,     -- <Tab> routed by customized settings ( see below )
        accept_word  = '<C-l>',
        accept_line  = '<C-M-l>',
        next         = '<M-]>',
        prev         = '<M-[>',
        dismiss      = '<C-]>',
      },
    },

    panel = {
      enabled = true,
      auto_refresh = true,
      keymap = {
        open       = '<M-p>',
        accept     = '<CR>',
        jump_prev  = '[[',
        jump_next  = ']]',
        refresh    = 'gr',
      },
      layout = { position = 'bottom', ratio = 0.4 },
    },

    filetypes = {
      ['*']       = true,
      html        = true,
      gitcommit   = true,
      markdown    = true,
      yaml        = true,
      groovy      = true,
      python      = true,
      Jenkinsfile = true,
      sh          = true,
    },
  })

  -- disable copilot for large files ( > 100 KB )
  vim.api.nvim_create_autocmd('BufReadPre', {
    group = vim.api.nvim_create_augroup( 'CopilotLargeFileNvim', { clear = true } ),
    callback = function(args)
      local stat = (vim.uv or vim.loop).fs_stat(args.file)
      if stat and stat.size > 100000 then
        vim.b.copilot_enabled = false
      end
    end,
  })

  -- <F2>: toggle copilot enable/disable ( robust version )
  vim.g.__copilot_disabled = vim.g.__copilot_disabled or false
  vim.keymap.set('n', '<F2>', function()
    if vim.g.__copilot_disabled then
      vim.cmd('Copilot enable')
      vim.g.__copilot_disabled = false
      vim.b.copilot_enabled = true
      vim.notify( ' Copilot Enabled', vim.log.levels.INFO, { title = 'Copilot' } )
    else
      vim.cmd('Copilot disable')
      vim.g.__copilot_disabled = true
      vim.b.copilot_enabled = false
      vim.notify( ' Copilot Disabled', vim.log.levels.INFO, { title = 'Copilot' } )
    end
  end, { silent = true, desc = 'Toggle Copilot (F2)' })

  else
    vim.notify( 'copilot.lua not found', vim.log.levels.WARN )
  end

-- 2) CopilotChat
pcall( function()
  require('CopilotChat').setup({
    debug = true,
    allow_insecure = true,
    show_folds = false,
  })
end )

-- insert mode: <tab>/<s-tab> smart routing (only for copilot / luasnip / tab; not trigger cmp)
vim.keymap.set('i', '<Tab>', function()
  local ok_sug, sug = pcall( require, 'copilot.suggestion' )
  if ok_sug and sug.is_visible() then
    sug.accept()      -- Copilot preferred ( highest priority )
    return ''
  end
  local ok_ls, ls = pcall( require, 'luasnip' )
  if ok_ls and ls.expand_or_jumpable() then
    ls.expand_or_jump()
    return ''
  end
  return t('<Tab>')   -- regular indent
end, { expr = true, silent = true, desc = 'Tab: Copilot > LuaSnip > Tab' })

vim.keymap.set('i', '<S-Tab>', function()
  local ok_ls, ls = pcall( require, 'luasnip' )
  if ok_ls and ls.jumpable(-1) then
    ls.jump(-1)
    return ''
  end
  return t('<S-Tab>')
end, { expr = true, silent = true, desc = 'S-Tab: LuaSnip back > S-Tab' })

--------------------------------------------------------------------------------
-- nvim-cmp：ONLY enabled in command line; disabled in insert mode ( handled by coc ).
-- <C-p>/<C-n> or <Tab>/<S-Tab> or <up>/<down> to navigate
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
      { {
          name = 'cmdline',
          option = {
            ignore_cmds = {
              'w', 'wa', 'wq', 'x', 'xa', 'q', 'qa', 'qall',
              'write', 'wall', 'wq', 'xit', 'xall', 'quit'
            },
          }
      } }
    ),
  })

  -- search using '/' and '?' for the word "buffer".
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
  })

  -- keymap for navigation in command line --
  local function t(keys) return vim.api.nvim_replace_termcodes( keys, true, true, true ) end
  -- ↑ / ↓
  vim.keymap.set('c', '<Down>', function()
    if cmp.visible() then vim.schedule( function() cmp.select_next_item() end ) return '' end
    return t('<Down>')
  end, { expr = true, silent = true })
  vim.keymap.set('c', '<Up>', function()
    if cmp.visible() then vim.schedule( function() cmp.select_prev_item() end ) return '' end
    return t('<Up>')
  end, { expr = true, silent = true })

end

pcall( require, 'tiktoken_core' )
