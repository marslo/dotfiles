#!/usr/bin/env bash
# shellcheck disable=SC2015
#=============================================================================
#     FileName : https-settings.sh
#       Author : marslo
#      Created : 2025-07-09 14:24:29
#   LastChange : 2026-01-14 18:15:09
#  Description : Set git include path to enable https or ssh
#=============================================================================

set -euo pipefail

declare -r CONFIG="${HOME}/.gitconfig"
# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"

function usage() {
  echo -e 'USAGE'
  echo -e "  \$ ${ME} [ --on | --off | --check [ssh|https] ]"
  echo -e '\nOPTIONS'
  echo -e '  --on                 enable https，disable ssh'
  echo -e '  --off                enable ssh，disable https'
  echo -e '  --check [ssh|https]  check current status, optionally specify ssh or https to check specific mode'
  exit 0
}

function info() {
  case "${1}" in
    'enabled'   ) printf "\033[0;3;36m%s enabled\033[0m\n"          "${2}" ;;
    'disabled'  ) printf "\033[0;3;35m%s disabled\033[0m\n"         "${2}" ;;
    'warn'      ) printf "\033[0;2;3;37m%s\033[0m\n"                "${2}" ;;
    'error'     ) printf "\033[0;31mERROR: \033[0;3;37m%s\033[0m\n" "${2}" ;;
    'unchanged' ) printf "\033[0;2;37m%s\033[0m\n"                  "${2}" ;;
    'changed'   ) printf "\033[0;36m%s\033[0m\n"                    "${2}" ;;
  esac
}

function isEnabled() {
  local mode="$1"
  grep -Eq "^[[:space:]]*path[[:space:]]*=.*\.${mode}[[:space:]]*$" "${CONFIG}"
}

function switchMode() {
  local enable="$1"
  local disable="$2"

  if isEnabled "${enable}" && ! isEnabled "${disable}"; then
    printf "%s %s %s %s\n" "$(info 'enabled' "${enable^^}")" "$(info 'unchanged' '(')"  "$(info 'disabled' "${disable^^}")" "$(info 'unchanged' ')')"
    return 0
  fi

  sed -i -E \
    -e "/^[[:space:]]*path[[:space:]]*=.*\.${disable}[[:space:]]*$/ s|^([[:space:]]*)(path)|\1# \2|" \
    -e "/^[[:space:]]*#[[:space:]]*path[[:space:]]*=.*\.${enable}[[:space:]]*$/ s|^([[:space:]]*)#[[:space:]]*(path)|\1\2|" \
    "${CONFIG}"
  printf "%s %s %s %s\n" "$(info 'enabled' "${enable^^}")" "$(info 'changed' '(')" "$(info 'disabled' "${disable^^}")" "$(info 'changed' ')')"
}

[[ $# -lt 1 ]] && usage

case "$1" in
  --on         ) switchMode "https" "ssh" ;;
  --off        ) switchMode "ssh" "https" ;;
  -c | --check ) mode="${2:-}"
                 case "${mode}" in
                   ssh   ) isEnabled 'ssh'   && { info 'enabled' 'SSH'  ; exit 0; } || { info 'disabled' 'SSH'  ; exit 1; } ;;
                   https ) isEnabled 'https' && { info 'enabled' 'HTTPS'; exit 0; } || { info 'disabled' 'HTTPS'; exit 1; } ;;
                   ''    ) if isEnabled   'ssh'  ; then info 'enabled' 'SSH'   ;
                           elif isEnabled 'https'; then info 'enabled' 'HTTPS' ;
                           else info 'warn' 'no valid include path ( .ssh or .https ) ...'; exit 1;
                           fi
                           ;;
                   *    ) info 'error' "unknown mode '${mode}' for \`--check\` option"; exit 2 ;;
                 esac
                 if [[ -n "${mode:-}" ]]; then shift 2; else shift; fi
                 ;;
  -h | --help  ) usage ;;
  *            ) info 'error' "unknown option '$1'"; exit 1 ;;
esac

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
