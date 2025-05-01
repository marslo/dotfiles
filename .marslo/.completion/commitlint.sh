#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : commitlint.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-04-24 23:56:54
#   LastChange : 2025-04-25 00:27:06
#=============================================================================

_commitlint_completions() {
  # shellcheck disable=SC2034
  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword

  local all_opts="
    -c --color
    -g --config
       --print-config
    -d --cwd
    -e --edit
    -E --env
    -x --extends
    -H --help-url
    -f --from
       --from-last-tag
       --git-log-args
    -l --last
    -o --format
    -p --parser-preset
    -q --quiet
    -t --to
    -V --verbose
    -s --strict
       --options
    -v --version
    -h --help
  "

  local format_opts="json json-str pretty"
  local print_config_opts='"" text json'
  local git_log_args="--first-parent --cherry-pick --no-merges --author= --since= --until= --grep="

  case "${prev}" in
    -g|--config|-e|--edit|-p|--parser-preset|--help-url)
      COMPREPLY=( $(compgen -f -- "${cur}") )
      return 0
      ;;
    -d|--cwd|-f|--from|-t|--to)
      COMPREPLY=( $(compgen -d -- "${cur}") )
      return 0
      ;;
    -o|--format)
      COMPREPLY=( $(compgen -W "${format_opts}" -- "${cur}") )
      return 0
      ;;
    --print-config)
      COMPREPLY=( $(compgen -W "${print_config_opts}" -- "${cur}") )
      return 0
      ;;
    --git-log-args)
      COMPREPLY=( $(compgen -W "${git_log_args}" -- "${cur}") )
      return 0
      ;;
  esac

  if [[ "${cur}" == "-" ]]; then
    COMPREPLY=( $(compgen -W "${all_opts}" -- "-") )
    return 0
  elif [[ "${cur}" == --* || "${cur}" == -* ]]; then
    COMPREPLY=( $(compgen -W "${all_opts}" -- "${cur}") )
    return 0
  fi

  if [[ ${cword} -eq 1 && "${cur}" == "" ]]; then
    COMPREPLY=( $(compgen -W "${all_opts}" -- "-") )
    return 0
  fi
}

complete -F _commitlint_completions commitlint

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
