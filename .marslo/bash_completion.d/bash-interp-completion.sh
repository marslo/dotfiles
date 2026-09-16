#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : bash-interp-completion.sh
#       Author : marslo
#      Created : 2026-09-15 23:40:00
#   LastChange : 2026-09-15 23:37:30
#=============================================================================
#
# unified `bash <script> …` / `sh <script> …` completion dispatcher.
#
# MUST be sourced LAST ( after imarslo.sh and pythia's completion.bash ) so the per-script logic functions it delegates to ( _jira_ls_logic / _jira_stat_logic / _pythia_install / _pythia / … )
# already exist. owning bash/sh in a single place avoids the clobber and mutual-recursion problems of each tool hooking bash/sh on its own.

# script basename -> the completion logic that should handle it
# -g forces global scope: this file may be sourced from inside a function ( e.g. via .completion ),
# where a plain `declare -A` would be local and vanish, leaving the map empty at completion time
declare -gA _INTERP_MAP=(
  ['jira-ls']='_jira_ls_logic'
  ['jira-stat']='_jira_stat_logic'
  ['pythia']='_pythia'
  ['hosioi']='_hosioi'
  ['pneuma']='_pneuma'
  ['install.sh']='_pythia_install'
)

# complete `bash /path/to/jira-ls --<TAB>` ( or sh, or with interpreter flags such as `bash -x` )
function _marslo_interp_completion() {
  local i base fn script path
  COMPREPLY=()

  # locate the script: the first non-flag word after the interpreter, before the word under the cursor
  for (( i = 1; i < COMP_CWORD; i++ )); do
    case "${COMP_WORDS[i]}" in
      -* ) continue ;;
      *  ) break ;;
    esac
  done
  test "${i}" -lt "${COMP_CWORD}" || return 0                              # still typing the path / no script yet

  base="${COMP_WORDS[i]##*/}"
  fn="${_INTERP_MAP[${base}]:-}"
  { test -n "${fn}" && declare -F "${fn}" >/dev/null 2>&1; } || return 0   # not ours, or its logic isn't loaded

  # 'install.sh' is a generic name: only take over ai-pythia's, mirroring pythia's own guard
  if test 'install.sh' = "${base}"; then
    script="${COMP_WORDS[i]}"
    case "${script}" in
      */* ) path="${script}" ;;
      *   ) path="$( command -v -- "${script}" 2>/dev/null )"
            { test -z "${path}" && test -f "${PWD}/${script}"; } && path="${PWD}/${script}" ;;
    esac
    { test -n "${path}" && command grep -q 'ai-pythia' -- "${path}" 2>/dev/null; } || return 0
  fi

  # re-base COMP_WORDS so the script becomes argv[0], run the logic, then restore
  local -a _saved=( "${COMP_WORDS[@]}" )
  local _savedCword="${COMP_CWORD}"
  COMP_WORDS=( "${COMP_WORDS[@]:i}" )
  COMP_CWORD=$(( COMP_CWORD - i ))
  "${fn}"
  COMP_WORDS=( "${_saved[@]}" )
  COMP_CWORD="${_savedCword}"
}

complete -o default -o bashdefault -F _marslo_interp_completion bash sh

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
