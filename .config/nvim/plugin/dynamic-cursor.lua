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
    local captures = vim.treesitter.get_captures_at_pos(0, row - 1, col)
    for _, ts_cap in ipairs(captures) do

      if ts_cap and ts_cap.capture then
        -- 1. direct capture-name match: some captures always mean "underlined" regardless of hl attrs
        --    e.g. markdown link labels are underlined by convention but the hl group may only be a link
        if ts_cap.capture:find("^markup%.link") then
          is_underlined = true
          break
        end

        -- 2. check "@capture" and "@capture.lang" with link=true to follow the full link chain
        local names = { "@" .. ts_cap.capture }
        if ts_cap.lang then
          table.insert(names, "@" .. ts_cap.capture .. "." .. ts_cap.lang)
        end
        for _, name in ipairs(names) do
          local hl = vim.api.nvim_get_hl(0, {name = name, link = true})
          if hl and (hl.underline or hl.undercurl) then
            is_underlined = true
            break
          end
        end
        if is_underlined then break end
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
  pattern = { "sh", "python", "groovy", "jenkinsfile", "lua", "markdown" },
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

-------------------------------------------------------------------
-- :DebugCursor  →  print extmarks + captures at cursor position --
vim.api.nvim_create_user_command('DebugCursor', function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1], pos[2]
  print("=== extmarks ===")
  local marks = vim.api.nvim_buf_get_extmarks(0, -1, {row-1, col}, {row-1, col}, {details = true, overlap = true})
  for _, mark in ipairs(marks) do
    local d = mark[4]
    if d and d.hl_group then
      local hl = vim.api.nvim_get_hl(0, {name = d.hl_group, link = false})
      print(string.format("  hl_group=%-50s underline=%s", d.hl_group, tostring(hl.underline)))
    end
  end
  print("=== ts captures ===")
  local captures = vim.treesitter.get_captures_at_pos(0, row-1, col)
  for _, c in ipairs(captures) do
    local hl_base      = vim.api.nvim_get_hl(0, {name = "@" .. c.capture,                       link = true})
    local hl_base_raw  = vim.api.nvim_get_hl(0, {name = "@" .. c.capture,                       link = false})
    local hl_lang      = c.lang and vim.api.nvim_get_hl(0, {name = "@" .. c.capture .. "." .. c.lang, link = true})  or nil
    local link_name    = hl_base_raw and hl_base_raw.link or nil
    print(string.format("  capture=%-40s lang=%-20s link=%-30s @base_ul=%s  @lang_ul=%s",
      c.capture,
      tostring(c.lang),
      tostring(link_name),
      tostring(hl_base and hl_base.underline),
      tostring(hl_lang and hl_lang.underline)))
  end
end, {})
-------------------------------------------------------------------

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
