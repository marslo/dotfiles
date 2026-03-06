#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2015
#=============================================================================
#     FileName : update.sh
#       Author : marslo
#      Created : 2025-11-14 19:43:32
#   LastChange : 2026-03-06 02:47:39
#=============================================================================

set -euo pipefail

source "${HOME}"/.marslo/bin/bash-colors.sh

# shellcheck disable=SC2155
declare -r HERE="$( cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )"
function info() { echo -e "$(c Ms)>> $1 $(c 0Gi)updated !$(c)"; }
function warn() { echo -e "$(c Ms)>> $1 $(c 0Ri)failed or timed out !$(c)"; }

type -P kubectl >/dev/null && {
  command kubectl completion bash           > "${HERE}"/kubectl.sh
  info "kubectl"
}

type -P npm     >/dev/null && {
  command npm completion                    > "${HERE}"/npm.sh
  info "npm"
}

type -P gh      >/dev/null && {
  command gh completion -s bash             > "${HERE}"/gh.bash.sh
  info "gh cli"
}

type -P bat     >/dev/null && {
  command bat --completion bash             > "${HERE}"/bat.sh
  info "bat"
}

type -P pipx    >/dev/null && {
  command register-python-argcomplete pipx  > "${HERE}"/pipx.sh
  info "pipx"
}

type -P pip     >/dev/null && {
  command pip completion --bash             > "${HERE}"/pip.sh
  info "pip"
}

type -P fzf     >/dev/null && {
  command fzf --bash                        > "${HERE}"/fzf.sh
  info "fzf"
}

type -P cheat   >/dev/null && {
  command cheat --completion bash           > "${HERE}"/cheat.sh
  info "cheat"
}

type -P poetry  >/dev/null && {
  command poetry completions bash | sed -E 's/_poetry_[a-f0-9]+_complete/_poetry_complete/g' > "${HERE}"/poetry.sh
  info "poetry"
}

type -P code   >/dev/null && {
  {
    curl --max-time 10 -fsSL https://github.com/microsoft/vscode/raw/main/resources/completions/bash/code | \
         sed 's/@@APPNAME@@/code/g' > "${HERE}/code.sh.tmp" && \
    mv "${HERE}/code.sh.tmp" "${HERE}/code.sh" && \
    info "code"
  } || warn "code"
}

type -P cht.sh  >/dev/null && {
  {
    command curl --max-time 10 -sf cheat.sh/:list          > "${HERE}/cht.sh/cht.sh.txt.tmp" && \
    mv "${HERE}/cht.sh/cht.sh.txt.tmp" "${HERE}/cht.sh/cht.sh.txt" && \

    command curl --max-time 10 -sf cht.sh/:bash_completion > "${HERE}/cht.sh/cht.sh.org.tmp" && \
    mv "${HERE}/cht.sh/cht.sh.org.tmp" "${HERE}/cht.sh/cht.sh.org" && \

    info "cht.sh"
  } || warn "cht.sh"
}

# cleanup
[[ -n "${HERE}" && -d "${HERE}" ]] && fd -t f -d 2 -u '\.tmp$' "${HERE}" -x rm 2>/dev/null || true

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
