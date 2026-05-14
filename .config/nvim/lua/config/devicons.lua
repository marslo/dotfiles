-- ~/.config/nvim/lua/config/devicons.lua
-- icons: https://www.nerdfonts.com/cheat-sheet
--   - `nf-dev`/`nf-md`/`nf-cod`/`nf-fa`/`nf-linux`/`nf-seti`
--   -  , , , 󰍔, , 󱊷

local ok, devicons = pcall( require, 'nvim-web-devicons' )
if not ok then return end

devicons.setup({
  color_icons = true,
  default = true,
  strict = true,
  variant = 'dark',
  override_by_extension = {
    ['log']          = { icon = '󱂅',  color = '#44788E', name = 'Log'        },
    ['json']         = { icon = '',  color = '#cbcb41', name = 'Json'       },
    ['md']           = { icon = '',  color = '#519aba', name = 'Markdown'   },
    ['groovy']       = { icon = '',  color = '#8FAA54', name = 'Groovy'     },
    ['java']         = { icon = '',                     name = 'Java'       },
    ['sh']           = { icon = '󱆃',  color = '#89e051', name = 'Shell'      },
    ['yaml']         = { icon = '',  color = '#9370db', name = 'Yaml'       },
    ['yml']          = { icon = '',  color = '#9370db', name = 'Yml'        },
    ['vim']          = { icon = '',  color = '#019833', name = 'Vim'        },
    ['snippets']     = { icon = '󰷺',  color = '#4682b4', name = 'Snippets'   },
    ['js']           = { icon = '',  color = '#cbcb41', name = 'Js'         },
    ['css']          = { icon = '',  color = '#fd7e14', name = 'Css'        },
    ['html']         = { icon = '',  color = '#e34c26', name = 'Html'       },
    ['sql']          = { icon = '',  color = '#dad8d8', name = 'Sql'        },
    ['png']          = { icon = '',  color = '#719899', name = 'Png'        },
    ['perm']         = { icon = '󰌋',  color = '#a074c4', name = 'Perm'       },
  },
  override_by_filename = {
    ['.vimrc']       = { icon = '',  color = '#808000', name = 'Vimrc'       },
    ['.viminfo']     = { icon = '',  color = '#808000', name = 'Viminfo'     },
    ['.gitconfig']   = { icon = '',  color = '#e2a84b', name = 'GitConfig'   },
    ['.gitignore']   = { icon = '',  color = '#6e7681', name = 'Gitignore'   },
    ['.git']         = { icon = '',  color = '#F05032', name = 'Git'         },
    ['.github']      = { icon = '󰊤',  color = '#79c0ff', name = 'Github'      },
    ['mbook']        = { icon = '',                     name = 'Gitbook'     },
    ['.npm']         = { icon = '',                     name = 'Npm'         },
    ['.ipython']     = { icon = '',                     name = 'iPython'     },
    ['.copilot']     = { icon = '',                     name = 'Copilto'     },
    ['.ssh']         = { icon = '󰣀',                     name = 'SSH'         },
    ['.iterm2']      = { icon = '',                     name = 'iTerm2'      },
    ['.kube']        = { icon = '',                     name = 'Kubernetes'  },
    ['.mongodb']     = { icon = '',                     name = 'MongoDB'     },
    ['.lesshst']     = { icon = '',                     name = 'LESS'        },
    ['.vault-token'] = { icon = '',  color = '#a074c4', name = 'Vault'       },
    ['workflows']    = { icon = '',                     name = 'Workflow'    },
    ['.bashrc']      = { icon = '󰘨',  color = '#0099BD', name = 'Bashrc'      },
    ['.profile']     = { icon = '󰙄',  color = '#BDBB72', name = 'Profile'     },
    ['jenkinsfile']  = { icon = '',                     name = 'Jenkinsfile' },
    ['vars']         = { icon = '󱅿',                     name = 'Vars'        },
    ['README.md']    = { icon = '󰽭',  color = '#519aba', name = 'README'      },
    ['COPYRIGHT']    = { icon = '󰗦',  color = '#ba55d3', name = 'Copyright'   },
  },
  override_by_operating_system = {
    ['apple'] = {
      icon = '',
      color = '#A2AAAD',
      cterm_color = '248',
      name = 'Apple',
    },
  },
})

devicons.set_default_icon( '' )

---------------------------------------------------------------------------- pattern matching
-- nvim-web-devicons has no pattern support; monkey-patch get_icon to fall
-- back to vim-devicons' g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols:
-- {
--     '.*vimrc.*'             : '',
--     '^settings$'            : '',
--     '^cmds$'                : '',
--     '^os$'                  : '',
--     '^highlight$'           : '',
--     '^autocmd$'             : '',
--     '^devicons$'            : '',
--     '^shortcuts$'           : '',
--     '^theme$'               : '',
--     '^.*extension$'         : '',
--     '^functions$'           : '',
--     '^unix$'                : '',
--     'Vagrantfile$'          : '',
--     '.*backbone.*\.js$'     : '',
--     '.*require.*\.js$'      : '',
--     '^post.*$'              : '󰷺',
--     '.*marslo.*$'           : '󰮯',
--     '.*materialize.*\.css$' : '',
--     '^validation$'          : '󰷺',
--     '^candidate$'           : '󰷺',
--     '^purifyer$'            : '󰷺',
--     '.*profile$'            : '󰙄',
--     '^release$'             : '󰷺',
--     '^unittests$'           : '󰷺',
--     '^doxygen$'             : '󰷺',
--     '^oncommit$'            : '󰷺',
--     '^klocwork$'            : '󰷺',
--     '^sync$'                : '󰷺',
--     '^agent$'               : '󰷺',
--     '^internal$'            : '󰷺',
--     '^headerGenerator$'     : '󰷺',
--     '^tester$'              : '󰷺',
--     '^monitor$'             : '󰷺',
--     '^pre.*$'               : '󰷺',
--     '^.*compiler.*$'        : '󰷺'
--     '.*materialize.*\.js$'  : '',
--     '.*angular.*\.js$'      : '',
--     '.*ignore$'             : '',
--     '.*[Jj]enkinsfile.*'    : '',
--     '.*jquery.*\.js$'       : '',
--     '.*rc$'                 : '󱍢',
--     '.*mootools.*\.js$'     : '',
--     '.*git.*$'              : '',
-- }

local pattern_colors = {
  ['.*ignore$']          = '#cd853f',
  ['.*git.*$']           = '#6c71c4',
  ['.*marslo.*$']        = '#e06c75',
  ['.*profile$']         = '#BDBB72',
  ['.*[Jj]enkinsfile.*'] = '#5F87FF',
  ['.*[Pp]ipeline.*']    = '#5F87FF',
  ['.*vimrc.*']          = '#808000',
  ['.*extension.*']      = '#d63384',
  ['.*%.bak$']           = '#293739',
}

local function get_pattern_icon( name )
  local patterns = vim.g.WebDevIconsUnicodeDecorateFileNodesPatternSymbols
  if not patterns or not name then return nil, nil end
  for pat, icon in pairs( patterns ) do
    if name:match( pat ) then
      local color = pattern_colors[pat]
      local hl = 'DevIconPattern_' .. pat:gsub( '[^%w]', '' )
      if vim.fn.hlexists( hl ) == 0 then
        vim.api.nvim_set_hl( 0, hl, { fg = color } )
      end
      return icon, hl
    end
  end
  return nil, nil
end

local orig_get_icon = devicons.get_icon
devicons.get_icon = function( name, ext, opts )
  local icon, hl = orig_get_icon( name, ext, opts )
  if icon and icon ~= '' and hl and hl ~= 'DevIconDefault' then return icon, hl end
  local pat_icon, pat_hl = get_pattern_icon( name )
  if pat_icon then return pat_icon, pat_hl end
  return icon, hl
end

-- vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=lua:
