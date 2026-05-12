#!/usr/bin/env bash
#=============================================================================
#     FileName : update.sh
#       Author : marslo
#      Created : 2026-05-12 01:48:34
#   LastChange : 2026-05-12 01:48:34
#=============================================================================

set -euo pipefail

# shellcheck disable=SC2155
declare -r HERE="$( cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )"
function info() { echo -e "$(c Ms)>> $1 $(c 0Gi)updated !$(c)"; }

type -P fzf >/dev/null && { command fzf --bash > "${HERE}"/fzf.bash; info "fzf bash"; }

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
