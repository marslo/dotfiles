#!/usr/bin/env bash
#=============================================================================
#     FileName : scc.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2024-02-26 03:02:14
#   LastChange : 2024-02-26 03:02:14
#=============================================================================

_scc() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="
     --avg-wage
     --binary
     --by-file
     --ci
     --cocomo-project-type
     --count-as
     --currency-symbol
     --debug
     --eaf float
     --exclude-dir
     -x --exclude-ext
     --file-gc-count
     -f --format
     --format-multi
     --gen
     --generated-markers
     -h --help
     -i --include-ext
     --include-symlinks
     -l --languages
     --large-byte-count
     --large-line-count
     -z --min-gen
     --min-gen-line-length
     --no-cocomo
     -c --no-complexity
     -d --no-duplicates
     --no-gen
     --no-gitignore
     --no-ignore
     --no-large
     --no-min
     --no-min-gen
     --no-size
     -M --not-match
     -o --output
     --overhead float
     --remap-all
     --remap-unknown
     --size-unit
     --sloccount-format
     -s --sort
     --sql-project
     -t --trace
     -v --verbose
     --version
     -w --wide
     --version"

  if [[ "$cur" =~ ^-|\+ ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
    return 0
  fi

  return 0
}

if [[ $- =~ i ]]; then
  complete -F _scc -o nosort -o bashdefault -o default scc
fi
