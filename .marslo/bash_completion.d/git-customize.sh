#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : git-customize.sh
#       Author : marslo
#      Created : 2025-12-11 21:28:56
#   LastChange : 2026-05-04 19:38:38
#=============================================================================

function _git_ca()     { _git_mcx;      }
function _git_ro()     { _git_checkout; }
function _git_rob()    { _git_checkout; }
function _git_bb()     { _git_checkout; }
function _git_pl()     { _git_checkout; }
function _git_pls()    { _git_checkout; }
function _git_del()    { _git_checkout; }
function _git_finda () { __gitcomp_nl "$(git --list-cmds=alias 2>/dev/null)"; }

function _git_nb() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  compopt +o nospace 2>/dev/null

  local i
  for (( i=1; i < COMP_CWORD; i++ )); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      declare -F _jira_ls_logic >/dev/null 2>&1 && {
        _jira_ls_logic
        [[ ${#COMPREPLY[@]} -eq 0 && -z "${cur}" ]] && COMPREPLY=( $(compgen -W "${_JIRA_LS_OPTS}" -- "") )
      }
      return 0
    fi
  done

  local options="-c --checkout -C --no-checkout -y --yes -i --interactive -v -vv -h --"
  case "${cur}" in
    -* ) COMPREPLY=( $(compgen -W "${options}" -- "${cur}") ) ;;
    *  ) COMPREPLY=() ;;
  esac
}

function _git_mcx() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local longOpt=false
  for (( i=1; i < COMP_CWORD; i++ )); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      longOpt=true
      break
    fi
  done

  if ${longOpt}; then
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
    --lintrc) COMPREPLY=( $(compgen -f -- "${cur}") ); return 0 ;;
  esac

  if [[ ${cur} == -* ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi
}

# for git reflog - must load after _git_reflog loaded
__git_log_common_options="${__git_log_common_options} --no-abbrev --no-walk --do-walk --walk-reflogs --expire= --expire-unreachable= --all --rewrite --updateref --stale-fix --dry-run --verbose --single-worktree"
function _git_stat() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  local i=1
  local longOpt=0
  while (( i < COMP_CWORD )); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      longOpt=1
      break
    fi
    (( i++ ))
  done

  if (( longOpt )); then
    if [[ "${cur}" == -* ]]; then
      compopt -o nospace 2>/dev/null
      COMPREPLY=( $(compgen -W "${__git_log_common_options}" -- "${cur}") )
    fi
    return 0
  fi

  case "${prev}" in
    -u|--user|--author|--account) return 0 ;;
  esac

  if [[ "${cur}" == -* ]]; then
    local opts="-a --all -l --lc --line-change -c --cc --commit-count -u --user --author --account -h --help -v --verbose --debug --"
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi
}

function _git_gerrit_stat() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "${prev}" in
    -r|--repo    ) return 0 ;;
    -b|--branch  ) if declare -F __git_complete_refs >/dev/null; then __git_complete_refs; fi; return 0 ;;
    -a|--author  ) COMPREPLY=( $(compgen -W "marslo" -- "${cur}") ); return 0 ;;
    --hostname   ) COMPREPLY=( $(compgen -W "sj1git1.cavium.com" -- "${cur}") ); return 0 ;;
    --netrc-file ) COMPREPLY=( $(compgen -f -- "${cur}") ); return 0 ;;
    --after|--before|--since) return 0 ;;
  esac

  if [[ "${cur}" == -* ]]; then
    local opts="
      -r --repo -b --branch -a --author
      --after --before --since
      --netrc-file --hostname
      -v -vv -vvv --verbose
      -h --help
    "
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi
}

function _git_changed() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  local i=1
  local longOpt=0
  while (( i < COMP_CWORD )); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      longOpt=1
      break
    fi
    (( i++ ))
  done

  if (( longOpt )); then return 0; fi

  if [[ "${cur}" == -* ]]; then
    local opts="
      -a --all
      -s --staged
      -us --unstaged
      -ut --untracked
      -i --ignored
      --all-titles --no-title
      -h --help
      --
    "
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi

  return 0
}

function _git_fd() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # shellcheck disable=SC2155
  case "${prev}" in
    -e|--ext|-f|--file|-g|--grep|-k|--keyword|-m|--message|--blob) return 0 ;;
    -u|--author) local authors=$( git log -1000 --format="%ae" 2>/dev/null | sort -u )
                 COMPREPLY=( $(compgen -W "${authors}" -- "${cur}") )
                 return 0 ;;
  esac

  if [[ "${cur}" == -* ]]; then
    local opts="
      --fzf --no-fzf
      -u --author
      -e --ext
      -f --file
      -g --grep
      -k --keyword
      -m --message
      --delete --no-delete
      --add --no-add
      --modify --no-modify
      --rename --no-rename
      --blob
      -v --verbose
      -h --help
    "
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi
}

complete -o bashdefault -o default -F _git_stat        git-stat 2>/dev/null || \
complete -o default                -F _git_stat        git-stat
complete -o bashdefault -o default -F _git_gerrit_stat git-gerrit-stat
complete -o bashdefault -o default -F _git_changed     git-changed
complete -o bashdefault -o default -F _git_fd          git-fd
complete -o bashdefault -o default -F _git_mcx         git-mcx
complete -o bashdefault -o default -F _git_nb          git-nb

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
