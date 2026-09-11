-- ~/.config/nvim/lua/config/nvim-treesitter.lua

---------------- this configure is for nvim-treesitter in main branch ----------------
-- @usage  :TSInstall <lang> / :TSUpdate / :TSUninstall <lang> / :TSInstallFromGrammar / :TSLog
--         ( main branch dropped built-in :TSInstallInfo — re-added below as a shim )
-- @custom :TSInstallInfo / :TSModuleInfo / :TSInstallAll (install missing) / :TSInstallAllForce (force refresh all) / :TSUpdateAll
-- @ensure_installed :TSInstallAll
-- @ensure_installed :TSInstall bash c cmake css csv diff dockerfile git_config git_rebase gitcommit gitignore groovy ini java jq json lua markdown python query ssh_config vim vimdoc xml yaml

local ts_group = vim.api.nvim_create_augroup( "NativeTreesitterHighlight", { clear = true } )

-- local fork for the groovy parser: :TSInstall/:TSUpdate build from this path, not download
-- macOS: nvim-treesitter's `tree-sitter build` is linker-signed -> re-sign or nvim crashes
--   codesign --force --sign - ~/.local/share/nvim/site/parser/groovy.so
pcall(function()
  require('nvim-treesitter.parsers').groovy = {
    install_info = {
      path    = '/opt/ts/tree-sitter-groovy.git',
      queries = 'queries',
    },
  }
end)

-- local fork for the git_config parser: emits `hotkey` nodes so after/queries/git_config/highlights.scm can `(hotkey) @nospell` them, comment prose stays spellable
-- same macOS re-sign caveat -> refresh via :TSUpdateGitConfig
pcall(function()
  require('nvim-treesitter.parsers').git_config = {
    install_info = {
      path    = '/opt/ts/tree-sitter-git-config.git',
      queries = 'queries',
    },
  }
end)

-- register language aliases
vim.treesitter.language.register( 'bash', { 'sh', 'zsh' } )
vim.treesitter.language.register( 'groovy', { 'Jenkinsfile' } )

-- using legacy syntax as fallback
local ft_ignore = {
  [""] = true,
  ["groovy"] = true,
  ["Jenkinsfile"] = true,
  ["jenkinsfile"] = true
}

local indent_bypass = {
  ["lua"] = true,
  -- vim -> vim_ts_indent() instead of a bypass
  -- ["vim"] = true
  ["sh"] = true,
  ["bash"] = true,
  ["zsh"] = true
}

-- vim-filetype indent with augroup awareness ( the vim parser treats augroup...END as flat siblings, not a compound block )
local function vim_ts_indent(lnum)
  local ts_indent = require('nvim-treesitter.indent').get_indent(lnum)
  local cur = vim.fn.getline(lnum):match('^%s*(.*)')
  if cur:match('^augroup%s+END') then return ts_indent end

  local depth = 0
  for i = lnum - 1, math.max(1, lnum - 500), -1 do
    local line = vim.fn.getline(i):match('^%s*(.*)')
    if line:match('^augroup%s+END') then
      depth = depth + 1
    elseif line:match('^augroup%s+%S') then
      if depth > 0 then
        depth = depth - 1
      else
        return ts_indent + vim.bo.shiftwidth
      end
    end
  end
  return ts_indent
end
_G._vim_ts_indent = vim_ts_indent

local function safe_ts_start(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end

  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype

  -- skip ft in ft_ignore, or a non-normal buftype
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
      vim.notify( "File size too large (> 200KB), Treesitter disabled", vim.log.levels.INFO )
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
      if ft == 'vim' then
        vim.bo[buf].indentexpr = "v:lua._vim_ts_indent(v:lnum)"
      elseif not indent_bypass[ft] then
        -- vim.bo[buf].indentexpr = "nvim_treesitter#indent()"
        -- vim.bo[buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        vim.bo[buf].indentexpr = "v:lua.require('nvim-treesitter.indent').get_indent(v:lnum)"
      end
    end
  end)
end

local ensure_installed = {
  'bash', 'c', 'cmake', 'css', 'csv', 'diff', 'dockerfile',
  'git_config', 'git_rebase', 'gitcommit', 'gitignore', 'groovy',
  'html', 'ini', 'java', 'jq', 'json', 'lua', 'markdown', 'markdown_inline', 'python',
  'query', 'ssh_config', 'vim', 'vimdoc', 'xml', 'yaml'
}

-- ensure_installed parsers nvim-treesitter hasn't installed yet.
-- get_installed('parsers') reads nvim-treesitter's own install dir ( path/OS-agnostic ), ignoring nvim-bundled parsers
-- -> a bundled-but-unmanaged parser shows as "to install" ( vim.treesitter.language.inspect used to mask those )
-- returns: missing[], installed[]
local function missing_parsers()
  local installed = require('nvim-treesitter').get_installed( 'parsers' )
  local set = {}
  for _, l in ipairs( installed ) do
    set[l] = true
  end
  local missing = {}
  for _, l in ipairs( ensure_installed ) do
    if not set[l] then
      table.insert( missing, l )
    end
  end
  table.sort( missing )
  table.sort( installed )
  return missing, installed
end

-- :TSInstallAll — install the missing ensure_installed parsers
local function install_all_parsers()
  vim.schedule(function()
    local to_install = missing_parsers()
    if #to_install > 0 then
      vim.notify( "Installing TS parsers in background: " .. table.concat( to_install, ", " ) )
      vim.cmd( "silent! TSInstall " .. table.concat( to_install, " " ) )
      vim.cmd( "redraw!" )
      vim.notify( "Installation started! Use :messages to check progress.", vim.log.levels.INFO )
    else
      vim.notify( "All ensure_installed parsers are managed by nvim-treesitter." )
    end
  end)
end
-- register the command :TSInstallAll
vim.api.nvim_create_user_command( 'TSInstallAll', install_all_parsers, {} )

-- :TSInstallAllForce — force-reinstall EVERY ensure_installed parser into ~/.local ( :TSInstallAll only fills gaps; use this after an nvim ABI bump )
-- groovy/git_config excluded: local forks needing a macOS re-sign -> :TSUpdateGroovy / :TSUpdateGitConfig
local function install_all_parsers_force()
  vim.schedule(function()
    local langs = {}
    local local_forks = { groovy = true, git_config = true }
    for _, lang in ipairs( ensure_installed ) do
      if not local_forks[lang] then
        table.insert( langs, lang )
      end
    end

    local list = table.concat( langs, ' ' )
    vim.notify( "Force-installing ALL TS parsers: " .. list, vim.log.levels.INFO )
    -- try the force form first; fall back to plain install if `!` is unsupported
    if not pcall( vim.cmd, 'TSInstall! ' .. list ) then
      vim.cmd( 'silent! TSInstall ' .. list )
    end
    vim.cmd( "redraw!" )
    vim.notify( "Force-install started! Use :messages to check progress.", vim.log.levels.INFO )
  end)
end
-- register the command :TSInstallAllForce
vim.api.nvim_create_user_command( 'TSInstallAllForce', install_all_parsers_force, {} )

-- :TSInstallInfo — main branch dropped the built-in; reproduce via missing_parsers()
-- "managed" = installed by nvim-treesitter (~/.local); bundled-only lang(s) show as "not managed / to install"
local function install_info()
  local missing, installed = missing_parsers()
  vim.notify( ("managed by nvim-treesitter (%d): %s"):format( #installed, table.concat( installed, ', ' ) ), vim.log.levels.INFO )
  if #missing > 0 then
    vim.notify( ("not managed / to install (%d): %s"):format( #missing, table.concat( missing, ', ' ) ), vim.log.levels.WARN )
  else
    vim.notify( "ensure_installed: all managed by nvim-treesitter.", vim.log.levels.INFO )
  end
end
-- register the command :TSInstallInfo
vim.api.nvim_create_user_command( 'TSInstallInfo', install_info, {} )

-- :TSModuleInfo — main branch dropped modules; report the buffer's TS state instead ( filetype, resolved lang, parser, highlight, indent )
local function module_info()
  local buf  = vim.api.nvim_get_current_buf()
  local ft   = vim.bo[buf].filetype
  local lang = vim.treesitter.language.get_lang( ft ) or ft
  local has_parser = pcall( vim.treesitter.language.inspect, lang )
  local hl_on = false
  pcall(function()
    hl_on = vim.treesitter.highlighter.active[buf] ~= nil
  end)
  local indent = vim.bo[buf].indentexpr

  vim.notify( table.concat( {
    'TS buffer info (main branch has no modules):',
    ('  filetype   : %s'):format( '' ~= ft and ft or '<none>' ),
    ('  language   : %s'):format( lang ),
    ('  parser     : %s'):format( has_parser and 'available' or 'MISSING' ),
    ('  highlight  : %s'):format( hl_on and 'on' or 'off' ),
    ('  indentexpr : %s'):format( '' ~= indent and indent or '<none>' ),
  }, '\n' ), vim.log.levels.INFO )
end
-- register the command :TSModuleInfo
vim.api.nvim_create_user_command( 'TSModuleInfo', module_info, {} )

-- :TSUpdateAll — async-update all parsers, then rebuild + re-sign the local forks via :TSUpdateGroovy / :TSUpdateGitConfig ( must run last; they're linker-signed -> crash on macOS )
-- the install task's completion callback makes the ordering reliable
vim.api.nvim_create_user_command('TSUpdateAll', function()
  local ok, install = pcall( require, 'nvim-treesitter.install' )
  if not ok then
    vim.notify('nvim-treesitter.install not available', vim.log.levels.ERROR)
    return
  end
  vim.notify('TSUpdate: updating parsers ...', vim.log.levels.INFO)
  local task = install.update(nil, { summary = true })
  task:await(function(err)
    vim.schedule(function()
      if err then
        vim.notify('TSUpdate failed: ' .. tostring(err), vim.log.levels.ERROR)
        return
      end
      for _, cmd in ipairs({ 'TSUpdateGroovy', 'TSUpdateGitConfig' }) do
        if vim.fn.exists(':' .. cmd) == 2 then
          vim.cmd(cmd)
        else
          vim.notify(cmd .. ' command not found (is ~/.marslo/vimrc.d/functions sourced?)', vim.log.levels.WARN)
        end
      end
    end)
  end)
end, { desc = 'Update all parsers, then rebuild + re-sign the local groovy & git_config parsers' })

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

-- install parsers via git, not curl (recommended)
pcall(function()
  require('nvim-treesitter.install').prefer_git = true
end)

-- override highlight queries from after/queries/{markdown,markdown_inline,json}/highlights.scm
for _, spec in ipairs({
  { lang = "markdown",        file = "after/queries/markdown/highlights.scm" },
  { lang = "markdown_inline", file = "after/queries/markdown_inline/highlights.scm" },
  { lang = "json",            file = "after/queries/json/highlights.scm" },
}) do
  local scm = vim.fn.stdpath("config") .. "/" .. spec.file
  local f = io.open(scm, "r")
  if f then
    vim.treesitter.query.set(spec.lang, "highlights", f:read("*a"))
    f:close()
  end
end

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:foldmethod=indent:
