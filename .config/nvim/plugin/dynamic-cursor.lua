-- ~/.config/nvim/plugin/dynamic_cursor.lua

-- to change the cursor shape dynamically to block based on whether the current position is underlined (e.g. for spellbad or syntax highlights)
-- This code checks the syntax and extmark highlights at the cursor position and updates the cursor shape accordingly

-- running in nvim only
if vim.fn.has('nvim') == 0 then return end

-- local GC_HOR = "n:hor10-Cursor-blinkwait300-blinkon200-blinkoff150,v-ve-r-cr:block-Cursor-blinkon0,i-ci-c-o:hor20-Cursor-blinkon0"
-- local GC_BLK = "n:block-Cursor-blinkwait300-blinkon200-blinkoff150,v-ve-r-cr:block-Cursor-blinkon0,i-ci-c-o:hor20-Cursor-blinkon0"

-- read from vimrc to avoid hardcoding and allow user customization
local GC_HOR = vim.o.guicursor
local GC_BLK = string.gsub(GC_HOR, "n:hor%d+", "n:block")

local current_state = "hor"

local function set_cursor(state)
  if state == "blk" and current_state ~= "blk" then
    vim.opt.guicursor = GC_BLK
    current_state = "blk"
  elseif state == "hor" and current_state ~= "hor" then
    vim.opt.guicursor = GC_HOR
    current_state = "hor"
  end
end

local function check_underline_at_cursor()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1]
  local col = pos[2]
  local is_underlined = false

  -- checking traditional vim syntax / spellbad highlighting
  local syn_id = vim.fn.synID(row, col + 1, 1)
  local trans_id = vim.fn.synIDtrans(syn_id)
  if vim.fn.synIDattr(trans_id, "underline") == "1" or vim.fn.synIDattr(trans_id, "undercurl") == "1" then
    is_underlined = true
  end

  -- checking with modern Treesitter / LSP injected highlights (extmarks)
  if not is_underlined then
    local marks = vim.api.nvim_buf_get_extmarks(0, -1, {row - 1, col}, {row - 1, col}, {details = true, overlap = true})
    for _, mark in ipairs(marks) do
      local details = mark[4]
      if details and details.hl_group then
        local hl = vim.api.nvim_get_hl(0, {name = details.hl_group, link = false})
        if hl and (hl.underline or hl.undercurl) then
          is_underlined = true
          break
        end
      end
    end
  end

  -- check Treesitter syntax highlights as a fallback
  if not is_underlined and pcall(require, "vim.treesitter") then
    -- get the syntax tree capture group at the current cursor position
    local captures = vim.treesitter.get_captures_at_pos(0, row - 1, col)
    for _, capture in ipairs(captures) do
      local hl = vim.api.nvim_get_hl(0, {name = capture.capture, link = false})
      if hl and (hl.underline or hl.undercurl) then
        is_underlined = true
        break
      end
    end
  end

  set_cursor(is_underlined and "blk" or "hor")
end

-- create a dedicated autocmd group
local dynamic_cursor_grp = vim.api.nvim_create_augroup( "DynamicCursorShape", { clear = true } )

-- check with filetype
vim.api.nvim_create_autocmd("FileType", {
  group = dynamic_cursor_grp,
  pattern = { "sh", "python", "groovy", "jenkinsfile", "lua" },
  callback = function(args)

    -- to avoid affect other buffers, binding CursorMoved only to the specific Buffer ID that triggered this filetype
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = dynamic_cursor_grp,
      buffer = args.buf,
      callback = check_underline_at_cursor
    })

    -- revert the cursor when leaving the specific buffer
    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
      group = dynamic_cursor_grp,
      buffer = args.buf,
      callback = function() set_cursor("hor") end
    })

  end
})

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
