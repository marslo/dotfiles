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
-- │      ; / ,      │ repeat last move same direction / opposite direction          │
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

for _, m in ipairs( move_maps ) do
  vim.keymap.set( { "n", "x", "o" }, m[1], function()
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
vim.keymap.set( { "n", "x", "o" }, ";", ts_repeat.repeat_last_move )
vim.keymap.set( { "n", "x", "o" }, ",", ts_repeat.repeat_last_move_opposite )
vim.keymap.set( { "n", "x", "o" }, "f", ts_repeat.builtin_f_expr, { expr = true } )
vim.keymap.set( { "n", "x", "o" }, "F", ts_repeat.builtin_F_expr, { expr = true } )
vim.keymap.set( { "n", "x", "o" }, "t", ts_repeat.builtin_t_expr, { expr = true } )
vim.keymap.set( { "n", "x", "o" }, "T", ts_repeat.builtin_T_expr, { expr = true } )

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:foldmethod=indent:
