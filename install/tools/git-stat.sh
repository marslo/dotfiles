#!/usr/bin/env bash

set -euo pipefail

declare BIN_DIR="${HOME}/.local/bin"
declare -A TOOLS=(
  ['main/.marslo/bin/git-stat']='marslo/dotfiles'
  ['master/bash-colors.sh']='ppo/bash-colors'
)
declare -a DISPLAY=()

# download
function download() {
  for tool in "${!TOOLS[@]}"; do
    local repo="${TOOLS[$tool]}"
    # shellcheck disable=SC2155
    local file="$(basename "${tool}")"
    printf ">> Downloading \033[0;33m'%s'\033[0m to \033[0;35m'%s'\033[0m\n" "${file}" "${BIN_DIR}"
    curl -fsSL --create-dirs -o "${BIN_DIR}"/"${file}" "https://github.com/${repo}/raw/${tool}"
    [[ "${file}" != *.* ]] && {
      chmod +x "${BIN_DIR}/${file}"
      DISPLAY+=( "\033[3;32m${file} --help\033[0m" )
    } || :
  done
}

# setup $PATH
function envsetup() {
  # shellcheck disable=SC2155
  local info="$(printf "%s or " "${DISPLAY[@]}")"
  info="${info% or }"
  # shellcheck disable=SC2015
  [[ ":${PATH}:" != *"${BIN_DIR}"* ]] && {
    test 'Darwin' = "$(uname -s)" && rcfile="${HOME}/.bash_profile" || rcfile="${HOME}/.bashrc"
    printf ">> Adding '%s' to PATH. reload your shell or \033[3;32m\`\$ source %s\`\033[0m. And try %b\n" "${BIN_DIR}" "${rcfile}" "${info}"
    echo "export PATH=\"${BIN_DIR}:\$PATH\"" >> "${rcfile}"
  } || {
    printf "All Set! Now try %b.\n" "${info}"
  }
}

# main
function main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --bin-dir ) BIN_DIR="$2"; shift 2 ;;
      *         ) echo "USAGE: $0 [--bin-dir <dir>]"; exit 1 ;;
    esac
  done

  download
  envsetup
}

main "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
