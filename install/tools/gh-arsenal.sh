#!/usr/bin/env bash
#=============================================================================
#     FileName : gh-setup.sh
#       Author : marslo
#      Created : 2026-02-12 21:15:49
#   LastChange : 2026-02-12 23:18:23
#  Description : to install and setup gh-ops and gh-new
#=============================================================================

# how to use:
#   # install in /tmp/bin
#   $ curl -fsSL https://github.com/marslo/dotfiles/raw/main/.marslo/bin/gh.d/gh-setup.sh | bash -s -- --bin-dir /tmp/bin
#   # or
#   $ bash <(curl -fsSL https://github.com/marslo/dotfiles/raw/main/.marslo/bin/gh.d/gh-setup.sh) --bin-dir /tmp/bin
#
#   # install in ~/.local/bin (default)
#   $ curl -fsSL https://github.com/marslo/dotfiles/raw/main/.marslo/bin/gh.d/gh-setup.sh | bash
#   $ or
#   $ bash <(curl -fsSL https://github.com/marslo/dotfiles/raw/main/.marslo/bin/gh.d/gh-setup.sh)

set -euo pipefail

# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare BIN_DIR="${HOME}/.local/bin"
declare -A TOOLS=(
  ['main/.marslo/bin/gh-ops']='marslo/dotfiles'
  ['main/.marslo/bin/gh-new']='marslo/dotfiles'
  ['master/bash-colors.sh']='ppo/bash-colors'
 )
declare -a EXTRA_CONFIG=( 'gh-ops-preview.jq' )
declare -a DISPLAY=()
declare -r USAGE="""
DESCRIPTION
  setup script to install gh-ops and gh-new

USAGE
  \$ ${ME} [OPTION]

OPTION
  --bin-dir <dir>   specify the directory to install the tools (default: ~/.local/bin)
  -h, --help        show this help message and exit

HOW TO USE
  # install in /tmp/bin
  \$ curl -fsSL https://github.com/marslo/dotfiles/raw/main/.marslo/bin/gh.d/${ME} | bash -s -- --bin-dir /tmp/bin

  # install in ~/.local/bin (default)
  \$ curl -fsSL https://github.com/marslo/dotfiles/raw/main/.marslo/bin/gh.d/${ME} | bash
"""

function showHelp(){ echo -e "${USAGE}"; exit 0; }

# download
function download() {
  for tool in "${!TOOLS[@]}"; do
    local repo="${TOOLS[${tool}]}"
    # shellcheck disable=SC2155
    local file="$(basename "${tool}")"
    printf ">> Downloading \033[0;33m'%s'\033[0m to \033[0;35m'%s'\033[0m\n" "${file}" "${BIN_DIR}"
    curl -fsSL --create-dirs -o "${BIN_DIR}/${file}" "https://github.com/${repo}/raw/${tool}"
    [[ "${file}" != *.* ]] && {
      chmod +x "${BIN_DIR}/${file}"
      DISPLAY+=( "\033[3;32m${file} --help\033[0m" )
    } || :
  done

  for conf in "${EXTRA_CONFIG[@]}"; do
    target="${BIN_DIR}/gh.d"
    printf ">> Downloading \033[0;33m'%s'\033[0m to \033[0;35m'%s'\033[0m\n" "${conf}" "${target}"
    curl -fsSL --create-dirs -o "${target}/${conf}" "https://github.com/marslo/dotfiles/raw/main/.marslo/bin/gh.d/${conf}"
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
    printf ">> Adding '%s' to PATH. reload your shell or \033[3;32m\`\$ source ${rcfile}\`\033[0m. And try %b\n" "${BIN_DIR}" "${info}"
    echo "export PATH=\"${BIN_DIR}:\$PATH\"" >> "${rcfile}"
  } || {
    printf "All Set! Now try %b.\n" "${info}"
  }
}

function postcheck() {
  local -a deps=( 'gh' 'jq' 'fzf' )
  for dep in "${deps[@]}"; do
    type -P "${dep}" >/dev/null || {
      printf "\033[0;31mERROR: '%s' is required but not found in PATH.\033[0m please install it first." "${dep}" >&2
    }
  done

  if gh api user --jq .login >/dev/null 2>&1; then
    printf ">> gh is authenticated as \033[0;32m'%s'\033[0m\n" "$(gh api user --jq .login)"
  else
    printf "\033[0;31mERROR: gh is not authenticated.\033[0m please run \033[3;32m\`\$ gh auth login\`\033[0m to authenticate.\n" >&2
  fi
}

# main
function main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --bin-dir   ) BIN_DIR="$2"; shift 2                   ;;
      -h | --help ) showHelp                                ;;
      *           ) echo "unknown option: '$1'" >&2; exit 1 ;;
    esac
  done

  download
  postcheck
  envsetup
}

main "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
