-- ~/.config/nvim/lua/config/nvim-treesitter-textobjects.lua

-- ┌─────────────────┬──────────────────────────────────────────────────────────────┐
-- │       KEY       │                       DESCRIPTION                            │
-- ├─────────────────┼──────────────────────────────────────────────────────────────┤
-- │     af / if     │ outer / inner function    ( vaf dif caf yif .. )             │
-- │     ac / ic     │ outer / inner class       ( vac dic cac yic .. )             │
-- │     aa / ia     │ outer / inner parameter   ( vaa dia caa yia .. )             │
-- │    agc / igc    │ outer / inner comment     ( vagc digc cagc .. )              │
-- ├─────────────────┼──────────────────────────────────────────────────────────────┤
-- │     ]m / [m     │ next / prev function start                                   │
-- │     ]M / [M     │ next / prev function end                                     │
-- │     ]] / [[     │ next / prev class start                                      │
-- │     ][ / []     │ next / prev class end                                        │
-- ├─────────────────┼──────────────────────────────────────────────────────────────┤
-- │    <leader>a    │ swap current parameter with next                             │
-- │    <leader>A    │ swap current parameter with previous                         │
-- ├─────────────────┼──────────────────────────────────────────────────────────────┤
-- │      ; / ,      │ repeat last move forward / backward                          │
-- │  f / F / t / T  │ builtin motions (repeatable with ; and ,)                    │
-- └─────────────────┴──────────────────────────────────────────────────────────────┘

require( "nvim-treesitter-textobjects" ).setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v',
      ['@function.outer']  = 'V',
      ['@class.outer']     = 'V',
    },
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
}

---------------------------------------------------------------------------- select
local select_textobject = require( "nvim-treesitter-textobjects.select" ).select_textobject
local select_maps = {
  { 'af', '@function.outer'  },
  { 'if', '@function.inner'  },
  { 'ac', '@class.outer'     },
  { 'ic', '@class.inner'     },
  { 'aa',  '@parameter.outer' },
  { 'ia',  '@parameter.inner' },
  { 'agc', '@comment.outer'   },
  { 'igc', '@comment.inner'   },
}
for _, m in ipairs( select_maps ) do
  vim.keymap.set( { "x", "o" }, m[1], function()
    select_textobject( m[2], "textobjects" )
  end, { desc = "TS " .. m[1] .. " " .. m[2] } )
end

---------------------------------------------------------------------------- move
local move = require( "nvim-treesitter-textobjects.move" )
local move_maps = {
  -- next start
  { ']m', move.goto_next_start,     '@function.outer' },
  { ']]', move.goto_next_start,     '@class.outer'    },
  -- next end
  { ']M', move.goto_next_end,       '@function.outer' },
  { '][', move.goto_next_end,       '@class.outer'    },
  -- previous start
  { '[m', move.goto_previous_start, '@function.outer' },
  { '[[', move.goto_previous_start, '@class.outer'    },
  -- previous end
  { '[M', move.goto_previous_end,   '@function.outer' },
  { '[]', move.goto_previous_end,   '@class.outer'    },
}

-- groovy/Jenkinsfile: regex fallback when parser produces an ERROR tree
-- matches: `def foo(`, `void foo(`, `String foo(`, `List<String> foo(`, etc.
local groovy_fn_pattern = [[\v^\s*%(%(public|private|protected|static|final|abstract|synchronized|def)\s+)*%(def|void|boolean|int|long|float|double|char|\u\w*%([<][^>]*[>])?)\s+\w+\s*\(]]

local groovy_ft = { groovy = true, Jenkinsfile = true, jenkinsfile = true }

local function groovy_move_fn(forward, to_end)
  local flags = "W" .. (not forward and "b" or "")
  if not to_end then
    vim.fn.search(groovy_fn_pattern, flags)
  else
    local found = vim.fn.search(groovy_fn_pattern, flags)
    if found > 0 then
      if vim.fn.search("{", "W") > 0 then
        vim.cmd("normal! %")
      end
    end
  end
end

for _, m in ipairs( move_maps ) do
  vim.keymap.set( { "n", "x", "o" }, m[1], function()
    if groovy_ft[vim.bo.filetype] and m[3] == "@function.outer" then
      local ok, parser = pcall(vim.treesitter.get_parser, 0)
      local use_regex = not ok or not parser
      if not use_regex then
        local tree = parser:parse()[1]
        use_regex = not tree or tree:root():type() == "ERROR"
      end
      if use_regex then
        local forward = m[1]:sub(1, 1) == "]"
        local to_end  = m[1]:sub(2, 2):match("%u") ~= nil
        groovy_move_fn(forward, to_end)
        return
      end
    end
    m[2]( m[3], "textobjects" )
  end, { desc = "TS " .. m[1] .. " " .. m[3] } )
end

---------------------------------------------------------------------------- swap
local swap = require( "nvim-treesitter-textobjects.swap" )
vim.keymap.set( "n", "<leader>a", function() swap.swap_next( "@parameter.inner" ) end,
  { desc = "TS swap next parameter" } )
vim.keymap.set( "n", "<leader>A", function() swap.swap_previous( "@parameter.inner" ) end,
  { desc = "TS swap prev parameter" } )

---------------------------------------------------------------------------- repeatable moves
local ts_repeat = require( "nvim-treesitter-textobjects.repeatable_move" )
vim.keymap.set( { "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next )
vim.keymap.set( { "n", "x", "o" }, ",", ts_repeat.repeat_last_move_previous )
vim.keymap.set( { "n", "x", "o" }, "f", ts_repeat.builtin_f_expr, { expr = true } )
vim.keymap.set( { "n", "x", "o" }, "F", ts_repeat.builtin_F_expr, { expr = true } )
vim.keymap.set( { "n", "x", "o" }, "t", ts_repeat.builtin_t_expr, { expr = true } )
vim.keymap.set( { "n", "x", "o" }, "T", ts_repeat.builtin_T_expr, { expr = true } )

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:foldmethod=indent:
