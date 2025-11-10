-- ~/.config/nvim/lua/config/copilot.lua
-- Copilot inline + CopilotChat + LuaSnip Tab Router + large size file + <F2> toggle

--------------------------------------------------------------------------------
-- 0) remove default <Tab>/<S-Tab> in Neovim 0.11 ( insert & select mode )
--------------------------------------------------------------------------------
for _, mode in ipairs({ 'i', 's' }) do
  pcall( vim.keymap.del, mode, '<Tab>'   )
  pcall( vim.keymap.del, mode, '<S-Tab>' )
end

local function t(keys) return vim.api.nvim_replace_termcodes( keys, true, true, true ) end

--------------------------------------------------------------------------------
-- 1) Copilot inline
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- 2) CopilotChat
--------------------------------------------------------------------------------
pcall( function()
  require('CopilotChat').setup({
    debug = true,
    allow_insecure = true,    -- https://github.com/deathbeam/dotfiles/blob/master/nvim/.config/nvim/lua/config/copilot.lua
    show_folds = false
  })
end )

--------------------------------------------------------------------------------
-- 3) insert mode: <tab>/<s-tab> smart routing (only for copilot / luasnip / tab; not trigger cmp)
--    NOTE: nvim-cmp is not triggered ( customized cmp in init.lua )
--------------------------------------------------------------------------------
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

-- vim:tabstop=4:softtabstop=4:shiftwidth=4:expandtab:filetype=lua:
