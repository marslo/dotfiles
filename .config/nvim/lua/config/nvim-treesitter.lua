-- ~/.config/nvim/lua/config/nvim-treesitter.lua

-- if nvim-treesitter is not installed, do nothing
local ok_cfg, ts_configs = pcall( require, 'nvim-treesitter.configs' )
if not ok_cfg then
  vim.notify( 'nvim-treesitter not found', vim.log.levels.WARN )
  return
end

-- to use git to install parsers ( instead of curl ) as highly recommended
pcall(function()
  require( 'nvim-treesitter.install' ).prefer_git = true
end)

-- :TSInstallInfo / :TSInstall <lang> / :TSUpdate <lang> / :TSUninstall <lang>
ts_configs.setup({
  ensure_installed = {
    'bash', 'c', 'cmake', 'css', 'csv', 'diff', 'dockerfile',
    'git_config', 'git_rebase', 'gitcommit', 'gitignore', 'groovy',
    'ini', 'java', 'jq', 'json','lua', 'markdown', 'python', 'powershell',
    'query', 'ssh_config', 'vim', 'vimdoc', 'xml', 'yaml'
  },
  sync_install  = true,
  auto_install  = true,
  ignore_install = { 'javascript' },

  indent = {
    enable = true,
    disable = { 'markdown', 'groovy', 'Groovy' },
  },

  highlight = {
    enable = true,
    disable = { 'markdown', 'groovy' },
    additional_vim_regex_highlighting = true,

    ['punctuation.bracket'] = '',
    ['constructor']         = '',
  },

  incremental_selection = {
    enable = false,
    keymaps = {
      init_selection    = '<CR>',
      node_incremental  = '<CR>',
      node_decremental  = '<BS>',
      scope_incremental = '<TAB>',
    },
  },

  rainbow = {
    enable = true,
    extended_mode = true,   -- also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil,   -- do not enable for files with more than n lines, int
  },
})

-- ========= OPTIONAL =========
-- 1) automatically disable highlighting for large files ( to maintain consistency with copilot large file strategy )
-- ts_configs.setup({
--   highlight = {
--     enable = true,
--     disable = function)(lang, buf)
--       local ok_stat, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
--       if ok_stat and stats and stats.size > 200 * 1024 then   -- 200KB threshold
--         return true
--       end
--       -- overlay your original disabled languages
--       return lang == 'markdown' or lang == 'groovy'
--     end,
--     additional_vim_regex_highlighting = true,
--   },
-- })

-- 2) extend the parser on demand to automatically install/update command prompts (only provide prompts, do not change behavior)
-- vim.api.nvim_create_user_command('TSUpdateAllSafe', function()
--   vim.notify( 'Running :TSUpdate', vim.log.levels.INFO, { title = 'Treesitter' } )
--   vim.cmd('TSUpdate')
-- end, {})

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
