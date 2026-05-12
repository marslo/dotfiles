-- ~/.config/nvim/lua/config/rainbow.lua
vim.opt.termguicolors = true

local palette = {
  { gui = "#E06C75", cterm = 203 },
  { gui = "#E5C07B", cterm = 221 },
  { gui = "#98C379", cterm = 114 },
  { gui = "#56B6C2", cterm = 73  },
  { gui = "#61AFEF", cterm = 75  },
  { gui = "#C678DD", cterm = 176 },
  { gui = "#D19A66", cterm = 173 },
  { gui = "#ABB2BF", cterm = 145 },
}

local function apply_rainbow_colors()
  for i, c in ipairs(palette) do
    local hl_name = ("RainbowDelimiter%d"):format(i)
    vim.api.nvim_set_hl(0, hl_name, { fg = c.gui, ctermfg = c.cterm, force = true })
  end
end

-- apply colors immediately
apply_rainbow_colors()

-- configure rainbow-delimiters plugin
local rb_ok, rb_setup = pcall(require, 'rainbow-delimiters.setup')
if rb_ok then
  rb_setup.setup({
    strategy = {
      [''] = 'rainbow-delimiters.strategy.global',
    },
    query = {
      [''] = 'rainbow-delimiters',
    },
    highlight = {
      "RainbowDelimiter1", "RainbowDelimiter2", "RainbowDelimiter3",
      "RainbowDelimiter4", "RainbowDelimiter5", "RainbowDelimiter6", "RainbowDelimiter7",
    },
  })
end

-- if colorscheme changes, re-apply colors
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_rainbow_colors,
})

-- force sync @Field color to GreenBold
vim.api.nvim_set_hl(0, "@function.macro.groovy", { link = "GreenBold", force = true })
-- yellow italic for @type.builtin.groovy to highlight Map/List types
vim.api.nvim_set_hl(0, "@type.builtin.groovy", { fg = "#E5C07B", italic = true })

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
