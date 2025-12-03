#!/usr/bin/env bash
#=============================================================================
#     FileName : npm-groovy-lint.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-02-10 14:20:12
#   LastChange : 2025-02-10 14:20:12
#=============================================================================

_npm-groovy-lint() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="
      -c --config
      -f --files
      -h --help
      -i --ignorepattern
      -j --javaexecutable
      -l --loglevel
      -o --output
      -p --path
      -r --rulesets
      -s --source
      -v --version
      -x --fixrules
      --codenarcargs
      --ext
      --failon
      --failonerror
      --failoninfo
      --failonwarning
      --fix
      --format
      --insight
      --javaoptions
      --killserver
      --nolintafter
      --noserver
      --parse
      --returnrules
      --rulesetsoverridetype
      --serverhost
      --serverport
      --sourcefilepath
     --version"

  if [[ "$cur" =~ ^-|\+ ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
    return 0
  fi

  return 0
}

if [[ $- =~ i ]]; then
  complete -o default -F _npm-groovy-lint npm-groovy-lint
fi
