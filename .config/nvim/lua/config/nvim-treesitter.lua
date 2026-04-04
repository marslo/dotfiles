-- ~/.config/nvim/lua/config/nvim-treesitter.lua

---------------- this configure is for nvim-treesitter in main branch ----------------
-- @usage :TSInstallInfo / :TSInstall <lang> / :TSUpdate / :TSUninstall <lang>
-- @ensure_installed :TSInstallAll
-- @ensure_installed :TSInstall bash c cmake css csv diff dockerfile git_config git_rebase gitcommit gitignore groovy ini java jq json lua markdown python query ssh_config vim vimdoc xml yaml

local ts_group = vim.api.nvim_create_augroup( "NativeTreesitterHighlight", { clear = true } )

-- register language aliases
vim.treesitter.language.register( 'bash', { 'sh', 'zsh' } )
vim.treesitter.language.register( 'groovy', { 'Jenkinsfile' } )

local ft_ignore = {
  [""] = true,
  ["markdown"] = true,
  ["markdown_inline"] = true,
  ["groovy"] = true,
  ["Jenkinsfile"] = true,
  ["jenkinsfile"] = true,
}

local indent_bypass = {
  ["lua"] = true
}

local function safe_ts_start(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end

  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype

  -- bypass the filetype in ft_ignore or buffertype is not empty
  if ft_ignore[ft] or bt ~= "" then
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.treesitter.stop, buf)
      end
    end)
    return
  end

  -- large file interception ( > 200KB )
  local buf_name = vim.api.nvim_buf_get_name(buf)
  if buf_name ~= "" then
    local ok_stat, stats = pcall( vim.uv.fs_stat, buf_name )
    if ok_stat and stats and stats.size > 200 * 1024 then
      vim.notify( "File too large, Treesitter disabled", vim.log.levels.INFO )
      return
    end
  end

  local lang = vim.treesitter.language.get_lang(ft) or ft

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    -- enable highlight
    local ok, _ = pcall( vim.treesitter.start, buf, lang )
    if ok then
      -- enable indent
      if not indent_bypass[ft] then
        -- vim.bo[buf].indentexpr = "nvim_treesitter#indent()"
        -- vim.bo[buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        vim.bo[buf].indentexpr = "v:lua.require('nvim-treesitter.indent').get_indent(v:lnum)"
      end
      if ft == 'groovy' or ft == 'Jenkinsfile' then
        vim.bo[buf].syntax = 'on'
      end
    end
  end)
end

local ensure_installed = {
  'bash', 'c', 'cmake', 'css', 'csv', 'diff', 'dockerfile',
  'git_config', 'git_rebase', 'gitcommit', 'gitignore', 'groovy',
  'ini', 'java', 'jq', 'json', 'lua', 'markdown', 'python',
  'query', 'ssh_config', 'vim', 'vimdoc', 'xml', 'yaml'
}

-- for :TSInstallAll command
local function install_all_parsers()
  vim.schedule(function()
    local to_install = {}

    for _, lang in ipairs(ensure_installed) do
      local ok = pcall( vim.treesitter.language.inspect, lang )
      if not ok then
        table.insert( to_install, lang )
      end
    end

    if #to_install > 0 then
      vim.notify( "Installing TS parsers in background: " .. table.concat(to_install, ", ") )
      vim.cmd( "silent! TSInstall " .. table.concat(to_install, " ") )
      vim.cmd( "redraw!" )
      vim.notify( "Installation started! Use :messages to check progress.", vim.log.levels.INFO )
    else
      vim.notify( "All TS parsers are already installed." )
    end
  end)
end
-- register the command :TSInstallAll
vim.api.nvim_create_user_command( 'TSInstallAll', install_all_parsers, {} )

-- autocmd
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = ts_group,
  callback = function( args )
    safe_ts_start( args.buf )
  end
})

-- execute immediately for the current buffer
if vim.api.nvim_get_vvar( "vim_did_enter" ) == 1 then
  safe_ts_start( vim.api.nvim_get_current_buf() )
end

-- to use git to install parsers ( instead of curl ) as highly recommended
pcall(function()
  require('nvim-treesitter.install').prefer_git = true
end)

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:foldmethod=indent:
