-- ~/.config/nvim/lua/config/devicons.lua

local ok, devicons = pcall( require, 'nvim-web-devicons' )
if not ok then return end

devicons.setup({
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

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
