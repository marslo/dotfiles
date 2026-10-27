#!/usr/bin/env bash
#=============================================================================
#     FileName : vim.bash
#       Author : marslo
#      Created : 2023-12-25 18:46:55
#   LastChange : 2026-10-26 18:42:28
#=============================================================================

_vim() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="
     -g
     -f --nofork
     -v
     -e
     -E
     -s
     -d
     -y
     -R
     -Z
     -m
     -M
     -b
     -l
     -C
     -N
     -V
     -D
     -n
     -r
     -r
     -L
     -A
     -H
     -T
     --not-a-term
     --gui-dialog-file
     --ttyfail
     -u
     -U
     --noplugin
     -p
     -o
     -O
     --cmd
     -c
     -S
     -s
     -w
     -W
     -x
     --remote
     --remote-silent
     --remote-wait
     --remote-wait-silent
     --remote-tab-silent
     --remote-tab-wait
     --remote-send
     --remote-expr
     --serverlist
     --servername
     --startuptime
     --log
     -i
     --clean
     -h --help
     --version"

  if [[ "$cur" =~ ^-|\+ ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
    return 0
  fi

  return 0
}

if [[ $- =~ i ]]; then
  complete -o default -F _vim vim
  complete -o default -F _vim vi
fi
