#!/usr/bin/env bash
# shellcheck source=/dev/null
#=============================================================================
#     FileName : build.sh
#       Author : marslo
#      Created : 2025-11-14 19:43:32
#   LastChange : 2026-02-26 13:41:53
#=============================================================================

set -euo pipefail

source "${HOME}"/.marslo/bin/bash-colors.sh

function info() { echo -e "$(c Ms)>> $1 $(c Gi)updated !$(c)"; }

type -P kubectl >/dev/null && command kubectl completion bash           > kubectl.sh
info "kubectl"
type -P npm     >/dev/null && command npm completion                    > npm.sh
info "npm"
type -P gh      >/dev/null && command gh completion -s bash             > gh.bash.sh
info "gh cli"
type -P bat     >/dev/null && command bat --completion bash             > bat.sh
info "bat"
type -P pipx    >/dev/null && command register-python-argcomplete pipx  > pipx.sh
info "pipx"
type -P pip     >/dev/null && command pip completion --bash             > pip.sh
info "pip"
type -P poetry  >/dev/null && command poetry completions bash           > poetry.sh
info "poetry"
curl -fsSL https://github.com/microsoft/vscode/raw/main/resources/completions/bash/code | sed 's/@@APPNAME@@/code/g' > code.sh
info "code"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
