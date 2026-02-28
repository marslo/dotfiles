#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : gitalias.sh
#       Author : marslo
#      Created : 2025-12-11 21:28:56
#   LastChange : 2026-02-27 23:31:53
#=============================================================================

function _git_rob() {
  _git_checkout
}

function _git_bb() {
  _git_checkout
}

function _git_pl() {
  _git_checkout
}

function _git_del() {
  _git_checkout
}

function _git_mcx() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local has_dash_dash=false
  for (( i=1; i < COMP_CWORD; i++ )); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      has_dash_dash=true
      break
    fi
  done

  if ${has_dash_dash}; then
    if [[ ${cur} == -* ]] || [[ -z ${cur} ]]; then
        COMPREPLY=( $(compgen -W "--help" -- "${cur}") )
    fi
    return 0
  fi

  opts="--body --no-body --footer --no-footer --diff --no-diff \
        --preview --no-preview --scope --no-scope --lint --no-lint \
        --global-lintrc --no-global-lintrc --lintrc \
        --breaking --breaking-change -h"

  case "${prev}" in
    --lintrc)
        COMPREPLY=( $(compgen -f -- "${cur}") )
        return 0
        ;;
  esac

  if [[ ${cur} == -* ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi
}

function _git_ca() {
  _git_mcx
}

complete -F _git_mcx git-mcx

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
