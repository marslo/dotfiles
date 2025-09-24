#!/usr/bin/env bash
# shellcheck disable=SC2015
#=============================================================================
#     FileName : https-settings.sh
#       Author : marslo
#      Created : 2025-07-09 14:24:29
#   LastChange : 2025-09-23 17:54:33
#  Description : Set git include path to enable https or ssh
#=============================================================================

set -euo pipefail

CONFIG="${HOME}/.gitconfig"

function usage() {
  echo "USAGE: $0 [ --on|--off|--check [ssh|https] ]"
  echo '  --on      enable https，disable ssh'
  echo '  --off     enable ssh，disable https'
  echo '  --check   check current status, optionally specify ssh or https to check specific mode'
  exit 1
}

function info() {
  if [[ 'enabled' = "${1}" ]];then
    printf "\033[0;3;36m%s enabled\033[0m\n" "${2}"
  elif [[ 'disabled' = "${1}" ]]; then
    printf "\033[0;3;35m%s disabled\033[0m\n" "${2}"
  elif [[ 'warn' = "${1}" ]]; then
    printf "\033[0;2;3;37m%s\033[0m\n" "${2}"
  fi
}

[[ $# -lt 1 ]] && usage

case "$1" in
  --on         )
    sed -i -E '/^[[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*$/ s|(.*)(path[[:space:]]*=.*\.ssh[[:space:]]*)|\1# \2|' "${CONFIG}"
    sed -i -E '/^[[:space:]]*# [[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*$/ s|([[:space:]]*)# ([[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*)|\1\2|' "${CONFIG}"
    printf "\033[0;3;36mHTTPS enabled\033[0m ( \033[0;3;35mSSH disabled\033[0m )\n";
    ;;
  --off        )
    sed -i -E '/^[[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*$/ s|(.*)(path[[:space:]]*=.*\.https[[:space:]]*)|\1# \2|' "${CONFIG}"
    sed -i -E '/^[[:space:]]*# [[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*$/ s|([[:space:]]*)# ([[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*)|\1\2|' "${CONFIG}"
    printf "\033[0;3;36mSSH enabled\033[0m ( \033[0;3;35mHTTPS disabled\033[0m )\n";
    ;;
  -c | --check )
    mode="${2:-}"
    hasSSH=$(grep -Eq '^[[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*$' "${CONFIG}" && echo true || echo false)
    hasHTTPS=$(grep -Eq '^[[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*$' "${CONFIG}" && echo true || echo false)
    case "${mode}" in
      ssh   ) "${hasSSH}"   && info 'enabled' 'SSH'   || info 'disabled' 'SSH'   ;;
      https ) "${hasHTTPS}" && info 'enabled' 'HTTPS' || info 'disabled' 'HTTPS' ;;
      ''    ) if "${hasSSH}"     ; then info 'enabled' 'SSH'   ;
              elif "${hasHTTPS}" ; then info 'enabled' 'HTTPS' ;
              else info 'warn' 'no valid include path ( .ssh or .https )'; exit 1;
              fi
              ;;
      *    ) info 'warn' "unknown check mode '${mode}'"; usage ;;
    esac
    [[ -n "${mode:-}" ]] && shift 2 && shift
    ;;
  -h | --help  ) usage ;;
  *            ) usage ;;
esac

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
