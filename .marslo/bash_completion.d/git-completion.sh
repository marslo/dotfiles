#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : git-completion.sh
#       Author : marslo
#      Created : 2025-12-11 21:28:56
#   LastChange : 2026-04-30 15:51:18
#=============================================================================

# unified session-level cache for all git subcommand completions: cmd -> opts string
declare -A _git_completion_opts_cache=()

# _git_completion_load_opts <git-subcmd>
#   populates _git_completion_opts_cache[<subcmd>] using a two-layer cache:
#     1: associative array (zero cost after first call per session)
#     2: file cache keyed by git version (persists across sessions, auto-invalidated when git is upgraded)
function _git_completion_load_opts() {
  local cmd="$1"
  [[ -n "${_git_completion_opts_cache[${cmd}]}" ]] && return 0

  local cacheDir="${HOME}/.marslo/bash_completion.d"
  [[ -d "${cacheDir}" ]] || cacheDir="${XDG_CACHE_HOME:-${HOME}/.cache}"
  cacheDir+='/git-completion'

  local cacheFile="${cacheDir}/${cmd}-opts"
  local verFile="${cacheDir}/${cmd}-ver"
  local git_ver
  git_ver="$(git --version 2>/dev/null)"

  if [[ -s "${cacheFile}" ]] && [[ "$(<"${verFile}" 2>/dev/null)" == "${git_ver}" ]]; then
    _git_completion_opts_cache["${cmd}"]="$(<"${cacheFile}")"
  else
    local docDir
    docDir="$(git --html-path 2>/dev/null)"
    if [[ -f "${docDir}/git-${cmd}.html" ]]; then
      _git_completion_opts_cache["${cmd}"]="$(
        command grep -oP '(?<=<code>)--[a-zA-Z0-9][a-zA-Z0-9_-]*(\[?=)?' "${docDir}/git-${cmd}.html" |
        sed 's/\[=/=/' |
        sort -u |
        tr '\n' ' '
      )"
      mkdir -p "${cacheDir}"
      printf '%s'   "${_git_completion_opts_cache[${cmd}]}" > "${cacheFile}"
      printf '%s\n' "${git_ver}"                            > "${verFile}"
    fi
  fi
}

function _git_rev_parse() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ "${cur}" == -* ]]; then
    _git_completion_load_opts 'rev-parse'
    compopt -o nospace 2>/dev/null
    COMPREPLY=( $(compgen -W "${_git_completion_opts_cache[rev-parse]}" -- "${cur}") )
    return 0
  fi

  if declare -F __git_complete_refs >/dev/null; then
    __git_complete_refs
  fi
}

function _git_rev_list() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ "${cur}" == -* ]]; then
    _git_completion_load_opts 'rev-list'
    compopt -o nospace 2>/dev/null
    COMPREPLY=( $(compgen -W "${_git_completion_opts_cache[rev-list]}" -- "${cur}") )
    return 0
  fi

  if declare -F __git_complete_refs >/dev/null; then
    __git_complete_refs
    return 0
  fi
}

function _git_var() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ "${cur}" == -* ]]; then
    COMPREPLY=( $(compgen -W "-l" -- "${cur}") )
    return 0
  fi

  local vars="
    GIT_COMMITTER_IDENT
    GIT_AUTHOR_IDENT
    GIT_EDITOR
    GIT_SEQUENCE_EDITOR
    GIT_PAGER
    GIT_DEFAULT_BRANCH
    GIT_SHELL_PATH
    GIT_ATTR_SYSTEM
    GIT_ATTR_GLOBAL
    GIT_CONFIG_SYSTEM
    GIT_CONFIG_GLOBAL
  "
  COMPREPLY=( $(compgen -W "${vars}" -- "${cur}") )
  return 0
}

# to to revert to latest & default bash completion via :
# $ source /opt/homebrew/etc/bash_completion.d/git-completion.bash
function _git_config() {
  local subcommands subcommand
  if ! declare -f __git_resolve_builtins >/dev/null; then
    return
  fi

  __git_resolve_builtins "config"
  # shellcheck disable=SC2154
  subcommands="${___git_resolved_builtins}"
  subcommand="$(__git_find_subcommand "$subcommands")"

  # additional options for top-level (no subcommand) completion - which is deprecated
  if [ -z "$subcommand" ]; then
    case "$cur" in
      --*) local topOps="
                --global --system --local --worktree --file --blob
               --list --get --get-all --get-regexp --get-urlmatch --get-color --get-colorbool
               --add --unset --unset-all --rename-section --remove-section --edit
               --replace-all --append --comment --all --regexp --url= --value= --no-value
               --fixed-value --type --bool --int --bool-or-int --path --expiry-date --no-type
               --null --name-only --show-names --no-show-names --show-origin --show-scope
               --includes --no-includes --default
           "
           __gitcomp "${topOps}"
           return
           ;;
        # short options
        -*) __gitcomp "-f -l -e -z"
           return
           ;;
      *) if [[ "${cur}" == *.* ]]; then
           # show variable names for `git config -<TAB>` or `git config --<TAB>`
           __git_complete_config_variable_name
         else
           # show subcommand for `git config <TAB>`
           __gitcomp "${subcommands}"
         fi
         return
         ;;
    esac
  fi

  # `git config <subcommand> --...` options
  case "${cur}" in
    --*) __gitcomp_builtin "config_${subcommand}"; return ;;
  esac

  # keep the original variable name/value filtering logic for subcommands
  case "$subcommand" in
    get   ) __gitcomp_nl "$(__git_config_get_set_variables)" ;;
    set   ) case "${prev}" in
                *.* ) __git_complete_config_variable_value   ;;
                *   ) __git_complete_config_variable_name    ;;
            esac
                                                             ;;
    unset ) __gitcomp_nl "$(__git_config_get_set_variables)" ;;
  esac
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
