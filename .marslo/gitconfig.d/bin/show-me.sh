#!/usr/bin/env bash
#=============================================================================
#     FileName : show-me.sh
#       Author : marslo
#      Created : 2026-01-14 19:06:20
#   LastChange : 2026-01-14 21:13:07
#=============================================================================

set -euo pipefail

function show() {
  case "${1}" in
    'mail'   ) printf "\033[0;3;36m%s\033[0m\n"                  "${2}" ;;
    'name'   ) printf "\033[0;3;35m%s\033[0m\n"                  "${2}" ;;
    'local'  ) printf "\033[0;1;2;3;33m%s\033[0m"                "${2}" ;;
    'global' ) printf "\033[0;1;2;3;32m%s\033[0m"                "${2}" ;;
    'others' ) printf "\033[0;1;2;3;37m%s\033[0m"                "${2}" ;;
    'warn'   ) printf "\033[0;2;3;3;37m%s\033[0m\n"              "${2}" ;;
    'error'  ) printf "\033[0;31mERROR: \033[0;3;37m%s\033[0m\n" "${2}" ;;
  esac
}

function showScope(){
  local scope=''
  local file=''

  while read -r _scope _file _value; do
    local sColor=''
    case "${_scope}" in
      'local' | 'global' ) sColor="${_scope}" ;;
      *                  ) sColor='others'    ;;
    esac
    # scope="$(echo "${_scope:0:1}" | tr '[:lower:]' '[:upper:]')"
    scope="${_scope:0:1}"

    if [[ "${_file}" == *"gitconfig.d/"* ]]; then
      file="${_file##*gitconfig.d/}"
    else
      _file="${_file#file:}"
      file="${_file/#$HOME/\~}"
    fi
  done< <(git config --show-scope --show-origin user.name)

  printf "\t\t%s %s %s" "$(show warn '#')" \
                        "$(show warn "${file}")" \
                        "$(show "${sColor}" "[${scope}]")"
}

function showMe() {
  printf "%s <%s> %s" "$(show name "$(git config user.name)")" \
                      "$(show mail "$(git config user.email)")" \
                      "$(showScope)"
}

showMe

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
