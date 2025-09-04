#!/usr/bin/env bash
#=============================================================================
#     FileName : include-set.sh
#       Author : marslo
#      Created : 2025-07-09 14:24:29
#   LastChange : 2025-07-09 15:07:12
#  Description : Set git include path to enable https or ssh
#=============================================================================

set -euo pipefail

CONFIG="${HOME}/.gitconfig"

function usage() {
  echo "USAGE: $0 [ --on|--off|--check ]"
  echo '  --on      enable https，disable ssh'
  echo '  --off     enable ssh，disable https'
  echo '  --check   check current status'
  exit 1
}

[[ $# -ne 1 ]] && usage

case "$1" in
  --on        )
    sed -i -E '/^[[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*$/ s|(.*)(path[[:space:]]*=.*\.ssh[[:space:]]*)|\1# \2|' "${CONFIG}"
    sed -i -E '/^[[:space:]]*# [[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*$/ s|([[:space:]]*)# ([[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*)|\1\2|' "${CONFIG}"
    printf "\033[0;3;36mHTTPS enabled\033[0m ( \033[0;3;35mSSH disabled\033[0m )\n";
    ;;
  --off       )
    sed -i -E '/^[[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*$/ s|(.*)(path[[:space:]]*=.*\.https[[:space:]]*)|\1# \2|' "${CONFIG}"
    sed -i -E '/^[[:space:]]*# [[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*$/ s|([[:space:]]*)# ([[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*)|\1\2|' "${CONFIG}"
    printf "\033[0;3;36mSSH enabled\033[0m ( \033[0;3;35mHTTPS disabled\033[0m )\n";
    ;;
  --check     )
    if grep -Eq '^[[:space:]]*path[[:space:]]*=.*\.ssh[[:space:]]*$' "${CONFIG}"; then
      printf "\033[0;3;36mSSH enabled\033[0m\n"; exit 2;
    fi
    if grep -Eq '^[[:space:]]*path[[:space:]]*=.*\.https[[:space:]]*$' "${CONFIG}"; then
      printf "\033[0;3;36mHTTPS enabled\033[0m\n"; exit 0;
    fi
    printf "\033[0;2;3;37mno valid include path ( .ssh or .https )\033[0m\n"; exit 1;
    ;;
  -h | --help ) usage ;;
  *           ) usage ;;
esac

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
