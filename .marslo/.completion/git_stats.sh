#!/usr/bin/env bash
#=============================================================================
#     FileName : git_stats.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2024-02-26 03:02:14
#   LastChange : 2024-02-26 03:16:09
#=============================================================================

_git_stats() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="
     generate
     help
     version"

  if [[ "$cur" =~ ^-|\+ ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
    return 0
  fi

  return 0
}

if [[ $- =~ i ]]; then
  complete -F _git_stats -o nosort -o bashdefault -o default git_stats
fi
