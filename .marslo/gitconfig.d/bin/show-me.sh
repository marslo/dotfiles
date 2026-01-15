#!/usr/bin/env bash
# shellcheck disable=SC2155
#=============================================================================
#     FileName : show-me.sh
#       Author : marslo
#      Created : 2026-01-14 19:06:20
#   LastChange : 2026-01-14 22:00:14
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

function setPath() {
  local path="${1#file:}"
  # shellcheck disable=SC2015
  [[ "${path}" == *"gitconfig.d/"* ]] && echo "${path##*gitconfig.d/}" || echo "${path/#$HOME/\~}"
}


function getScopeColor() {
  local _result=''
  case "${1}" in
    'local' | 'global' ) _result="${1}"   ;;
    *                  ) _result='others' ;;
  esac
  echo "${_result}"
}

function getInitials() {
  local name="${1}"
  local capitalized=${2:-false}
  name="${name:0:1}"
  [[ "${capitalized}" == true ]] && echo "${name^^}" || echo "${name}"
}

function showScope(){
  local scope=''
  local file=''

  read -r nScope nPath _ <<< "$(git config --show-scope --show-origin user.name  2>/dev/null)"
  read -r eScope ePath _ <<< "$(git config --show-scope --show-origin user.email 2>/dev/null)"

  # file:<path>
  local nFile="$(setPath "${nPath}")"
  local eFile="$(setPath "${ePath}")"
  [[ "${nPath}" == "${ePath}" ]] && file="${nFile}" || file="${nFile} <${eFile}>"

  # scope
  scope="$(show "$(getScopeColor "${nScope}")"  "$(getInitials "${nScope}" true)")"
  if [[ "${nScope}" != "${eScope}" ]]; then
    scope+="$(show warn ' <')"
    scope+="$(show "$(getScopeColor "${eScope}")" "$(getInitials "${eScope}" true)")"
    scope+="$(show warn '>')"
  fi

  printf "\t\t%s %s %s%s%s" "$(show warn '#')" \
                            "$(show warn "${file}")" \
                            "$(show warn "[")" \
                            "${scope}" \
                            "$(show warn "]")"
}

function main() {
  printf "%s <%s> %s" "$(show name "$(git config user.name)")" \
                      "$(show mail "$(git config user.email)")" \
                      "$(showScope)"
}

main "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
