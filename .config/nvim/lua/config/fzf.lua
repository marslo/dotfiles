-- ~/.config/nvim/lua/config/fzf.lua

local ok, fzf = pcall(require, 'fzf-lua')
if not ok then return end

fzf.register_ui_select()

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
