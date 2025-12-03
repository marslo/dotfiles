#!/usr/bin/env bash
# shellcheck source=/dev/null

set -euo pipefail

source "${HOME}"/.marslo/bin/bash-color.sh

function info() { echo -e "$(c Ms)>> $1 $(c Gi)updated !$(c)"; }

type -P kubectl >/dev/null && command kubectl completion bash           > kubectl.sh
info "kubectl"
type -P npm     >/dev/null && command npm completion                    > npm.sh
info "npm"
type -P gh      >/dev/null && command gh copilot alias -- bash          > gh.bash.sh
info "gh copilot"
type -P bat     >/dev/null && command bat --completion bash             > bat.sh
info "bat"
type -P pipx    >/dev/null && command register-python-argcomplete pipx  > pipx.sh
info "pipx"
type -P pip     >/dev/null && command pip completion --bash             > pip.sh
info "pip"
type -P poetry  >/dev/null && command poetry completions bash           > poetry.sh
info "poetry"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
