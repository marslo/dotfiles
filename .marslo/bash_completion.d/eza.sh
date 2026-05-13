#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : eza.sh
#       Author : marslo
#      Created : 2026-05-12 17:28:00
#   LastChange : 2026-05-12 17:30:13
#  Description : bash completion for eza v0.23.4
#                https://github.com/eza-community/eza
#=============================================================================

function _eza() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # options that take no further completion
  case "${prev}" in
    -\?|--help|-v|--version)
      return 0
      ;;
  esac

  # options that require an argument
  case "${prev}" in
    --color|--colour)
      COMPREPLY=( $(compgen -W 'always automatic auto never' -- "${cur}") )
      return 0
      ;;
    --icons)
      COMPREPLY=( $(compgen -W 'always automatic auto never' -- "${cur}") )
      return 0
      ;;
    -F|--classify)
      COMPREPLY=( $(compgen -W 'always auto never' -- "${cur}") )
      return 0
      ;;
    --color-scale|--colour-scale)
      COMPREPLY=( $(compgen -W 'all age size' -- "${cur}") )
      return 0
      ;;
    --color-scale-mode|--colour-scale-mode)
      COMPREPLY=( $(compgen -W 'fixed gradient' -- "${cur}") )
      return 0
      ;;
    --absolute)
      COMPREPLY=( $(compgen -W 'on follow off' -- "${cur}") )
      return 0
      ;;
    -L|--level)
      COMPREPLY=( $(compgen -W '1 2 3 4 5 6 7 8 9' -- "${cur}") )
      return 0
      ;;
    -s|--sort)
      COMPREPLY=( $(compgen -W '
        name Name filename Filename extension Extension
        size filesize type inode
        date time old new age none
        modified changed accessed created
      ' -- "${cur}") )
      return 0
      ;;
    -t|--time)
      COMPREPLY=( $(compgen -W 'modified accessed created changed' -- "${cur}") )
      return 0
      ;;
    --time-style)
      COMPREPLY=( $(compgen -W 'default iso long-iso full-iso relative' -- "${cur}") )
      return 0
      ;;
    -w|--width)
      return 0
      ;;
    -I|--ignore-glob)
      return 0
      ;;
  esac

  # handle --option=value style
  if [[ "${cur}" == --color=* || "${cur}" == --colour=* ]]; then
    COMPREPLY=( $(compgen -W 'always automatic auto never' -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/${cur%%=*}=}" )
    return 0
  fi
  if [[ "${cur}" == --icons=* ]]; then
    COMPREPLY=( $(compgen -W 'always automatic auto never' -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/${cur%%=*}=}" )
    return 0
  fi
  if [[ "${cur}" == --classify=* ]]; then
    COMPREPLY=( $(compgen -W 'always auto never' -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/${cur%%=*}=}" )
    return 0
  fi
  if [[ "${cur}" == --color-scale=* || "${cur}" == --colour-scale=* ]]; then
    COMPREPLY=( $(compgen -W 'all age size' -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/${cur%%=*}=}" )
    return 0
  fi
  if [[ "${cur}" == --color-scale-mode=* || "${cur}" == --colour-scale-mode=* ]]; then
    COMPREPLY=( $(compgen -W 'fixed gradient' -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/${cur%%=*}=}" )
    return 0
  fi
  if [[ "${cur}" == --absolute=* ]]; then
    COMPREPLY=( $(compgen -W 'on follow off' -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/${cur%%=*}=}" )
    return 0
  fi
  if [[ "${cur}" == --time-style=* ]]; then
    COMPREPLY=( $(compgen -W 'default iso long-iso full-iso relative' -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/${cur%%=*}=}" )
    return 0
  fi

  if [[ "${cur}" == --* ]]; then
    COMPREPLY=( $(compgen -W '
      --help
      --version
      --oneline
      --long
      --grid
      --across
      --recurse
      --tree
      --dereference
      --classify
      --color
      --colour
      --color-scale
      --colour-scale
      --color-scale-mode
      --colour-scale-mode
      --icons
      --no-quotes
      --hyperlink
      --absolute
      --follow-symlinks
      --width
      --all
      --almost-all
      --treat-dirs-as-files
      --only-dirs
      --only-files
      --show-symlinks
      --no-symlinks
      --level
      --reverse
      --sort
      --group-directories-first
      --group-directories-last
      --ignore-glob
      --git-ignore
      --binary
      --bytes
      --group
      --smart-group
      --header
      --links
      --inode
      --mounts
      --numeric
      --flags
      --blocksize
      --time
      --modified
      --accessed
      --created
      --changed
      --time-style
      --total-size
      --octal-permissions
      --no-permissions
      --no-filesize
      --no-user
      --no-time
      --stdin
      --git
      --no-git
      --git-repos
      --git-repos-no-status
      --extended
      --context
    ' -- "${cur}") )
    return 0
  fi

  if [[ "${cur}" == -* ]]; then
    COMPREPLY=( $(compgen -W '
      -? -v
      -1 -l -G -x -R -T -X -F -w
      -a -A -d -D -f -L -r -s -I
      -b -B -g -h -H -i -M -n -O -S
      -t -m -u -U -o
      -@ -Z
    ' -- "${cur}") )
    return 0
  fi

  _filedir
}

complete -o bashdefault -o filenames -F _eza eza

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
