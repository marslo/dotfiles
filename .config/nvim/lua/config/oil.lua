-- ~/.config/nvim/lua/config/oil.lua

-- Path-context rules: when browsing inside these directories, all unmatched
-- files inherit a context icon.  Mirrors vim-devicons' conditional .* patterns.
--   { <path_segment>, <pattern_key_in_vim_g>, <fallback_color> }
--   { <path_segment>, <pattern_key_or_icon>,  <fallback_color> }
-- When the 2nd element is found in the vim-devicons pattern table it is used
-- as a lookup key; otherwise it is treated as a literal icon character.
local path_context_rules = {
  { 'jenkinsfile',     '.*[Jj]enkinsfile.*', '#5F87FF' },
  { '.marslo/vimrc.d', '.*vimrc.*',          '#808000' },
  { '.ssh',            '󱦃',                  '#a074c4' },
}

-- Look up a context-dependent icon for files that have no individual match.
-- Checks whether the current oil directory contains a known path segment,
-- then pulls the icon character from vim-devicons' global pattern table.
local function get_context_icon( dir )
  if not dir then return nil, nil end
  local patterns = vim.g.WebDevIconsUnicodeDecorateFileNodesPatternSymbols
  for _, rule in ipairs( path_context_rules ) do
    if dir:find( rule[1], 1, true ) then
      local ctx_icon = patterns and patterns[rule[2]]
      if not ctx_icon or ctx_icon == '' then ctx_icon = rule[2] end
      if ctx_icon and ctx_icon ~= '' then
        local hl = 'DevIconCtx_' .. rule[1]:gsub( '[^%w]', '' )
        if vim.fn.hlexists( hl ) == 0 then
          vim.api.nvim_set_hl( 0, hl, { fg = rule[3] } )
        end
        return ctx_icon, hl
      end
    end
  end
  return nil, nil
end

-- Monkey-patch oil's icon provider so that:
--   1. Directory entries also go through nvim-web-devicons (and its pattern
--      fallback) instead of always showing a generic folder icon.
--   2. Unmatched files inside special directories receive a context icon.
-- Must run BEFORE require("oil").setup() so the patched provider is captured.
local oil_util = require( "oil.util" )
local orig_get_provider = oil_util.get_icon_provider
oil_util.get_icon_provider = function()
  local has_devicons, devicons = pcall( require, "nvim-web-devicons" )
  if has_devicons then
    return function( type, name, conf )
      if type == "directory" then
        local icon, hl = devicons.get_icon( name )
        if icon and icon ~= '' and hl and hl ~= "DevIconDefault" then return icon, hl end
        return conf and conf.directory or "", "OilDirIcon"
      else
        local icon, hl = devicons.get_icon( name )
        if icon and icon ~= '' and hl and hl ~= "DevIconDefault" then return icon, hl end
        local ctx_icon, ctx_hl = get_context_icon( require( "oil" ).get_current_dir() )
        if ctx_icon then return ctx_icon, ctx_hl end
        icon = icon or ( conf and conf.default_file or "" )
        return icon, hl
      end
    end
  end
  return orig_get_provider()
end

-- Winbar text for non-floating oil windows: show the shortened directory path.
-- Returns empty string for floating windows (they show the path in the title).
function OilWinbar()
  local win_cfg = vim.api.nvim_win_get_config( 0 )
  if win_cfg.relative ~= '' then return '' end
  local dir = require( "oil" ).get_current_dir()
  if dir then return vim.fn.fnamemodify( dir, ':~' ) end
  return ''
end

require( "oil" ).setup {
  columns = {
    { "icon", default_file = "", directory = "", add_padding = false },
  },
  default_file_explorer = true,
  float = {
    padding = 2,
    max_width = 0.6,
    max_height = 0.7,
    border = "rounded",
    win_options = {
      winblend = 10,
      cursorline = false,
    },
    -- show current directory path centered in the float border
    get_win_title = function()
      local dir = require( "oil" ).get_current_dir()
      if dir then return " " .. vim.fn.fnamemodify( dir, ":~" ) .. " " end
      return ""
    end,
    -- placeholder title required by nvim_open_win when title_pos is set;
    -- oil replaces it with get_win_title output after the window opens
    override = function( conf )
      conf.title = " "
      conf.title_pos = "center"
      return conf
    end,
  },
  keymaps = {
    ["q"] = "actions.close",
    ["u"] = "actions.parent",
  },
  view_options = {
    show_hidden = true,
  },
}

-- Enable winbar only for non-floating oil windows.
-- Applied via autocmd because oil's global win_options would override
-- the float's empty winbar setting otherwise.
vim.api.nvim_create_autocmd( "BufWinEnter", {
  pattern = "oil://*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config( win ).relative == '' then
      vim.wo[win].winbar = "%{%v:lua.OilWinbar()%}"
    end
  end,
} )

-- keymap settings
vim.keymap.set( "n", "<leader>-", "<CMD>Oil --float<CR>",   { desc = "Oil parent directory" } )
vim.keymap.set( "n", "<leader>_", "<CMD>Oil . --float<CR>", { desc = "Oil project root"     } )
vim.keymap.set( "n", "<leader>~", "<CMD>Oil ~ --float<CR>", { desc = "Oil home directory"   } )

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:foldmethod=indent:
