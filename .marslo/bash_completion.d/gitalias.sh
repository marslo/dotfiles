#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : gitalias.sh
#       Author : marslo
#      Created : 2025-12-11 21:28:56
#   LastChange : 2026-02-28 03:18:18
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

# for git reflog - must load after _git_reflog loaded
__git_log_common_options="${__git_log_common_options} --no-abbrev --no-walk --do-walk --walk-reflogs --expire= --expire-unreachable= --all --rewrite --updateref --stale-fix --dry-run --verbose --single-worktree"

_git_rev_list() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  local opts="
      --abbrev --abbrev-commit --all --alternate-refs --author=
      --committer= --basic-regexp --bisect --bisect-all --bisect-vars
      --boundary --branches= --cherry --cherry-mark --cherry-pick
      --children --count --date= --date-order --dense --disk-usage
      --do-walk --exclude= --exclude-first-parent-only --exclude-hidden=
      --exclude-promisor-objects --extended-regexp --filter=
      --filter-print-omitted --first-parent --fixed-strings --format=
      --glob= --grep= --grep-reflog= --header --ignore-missing
      --in-commit-order --invert-grep --left-only --left-right
      --max-age= --max-count= --max-parents= --merge --merges --min-age=
      --min-parents= --missing= --no-abbrev --no-abbrev-commit
      --no-commit-header --no-max-parents --no-min-parents
      --no-object-names --no-walk --not --objects --objects-edge
      --objects-edge-aggressive --parents --perl-regexp --pretty=
      --quiet --reflog --regexp-ignore-case --remotes= --reverse
      --right-only --show-linear-break --show-pulls --after=
      --simplify-by-decoration --simplify-merges --since= --since-as-filter=
      --skip= --sparse --tags= --topo-order --unpacked --until=
      --before= --use-bitmap-index --remove-empty --progress=
      --full-history --ancestry-path --author-date-order --indexed-objects
      --object-names --oneline --expand-tabs= --expand-tabs --no-expand-tabs
      --show-signature --relative-date --timestamp --graph
  "

  if [[ "$cur" == -* ]]; then
    compopt -o nospace 2>/dev/null
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi

  if declare -F __git_complete_refs >/dev/null; then
    __git_complete_refs
    return 0
  fi
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

function _git_stat() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  local i=1
  local has_dash_dash=0
  while (( i < COMP_CWORD )); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      has_dash_dash=1
      break
    fi
    (( i++ ))
  done

  if (( has_dash_dash )); then
    if [[ "$cur" == -* ]]; then
      compopt -o nospace 2>/dev/null
      COMPREPLY=( $(compgen -W "${__git_log_common_options}" -- "$cur") )
    fi
    return 0
  fi

  case "$prev" in
    -u|--user|--author|--account) return 0 ;;
  esac

  if [[ "$cur" == -* ]]; then
    local opts="-a --all -l --lc --line-change -c --cc --commit-count -u --user --author --account -h --help -v --verbose --debug --"
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi
}

function _git_gerrit_stat() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "$prev" in
    -r|--repo) return 0 ;;
    -b|--branch) if declare -F __git_complete_refs >/dev/null; then __git_complete_refs; fi; return 0 ;;
    -a|--author) COMPREPLY=( $(compgen -W "marslo" -- "$cur") ); return 0 ;;
    --hostname) COMPREPLY=( $(compgen -W "sj1git1.cavium.com" -- "$cur") ); return 0 ;;
    --netrc-file) COMPREPLY=( $(compgen -f -- "$cur") ); return 0 ;;
    --after|--before|--since) return 0 ;;
  esac

  if [[ "$cur" == -* ]]; then
    local opts="
        -r --repo -b --branch -a --author
        --after --before --since
        --netrc-file --hostname
        -v -vv -vvv --verbose
        -h --help
    "
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi
}

_git_changed() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  local i=1
  local has_dash_dash=0
  while (( i < COMP_CWORD )); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      has_dash_dash=1
      break
    fi
    (( i++ ))
  done

  if (( has_dash_dash )); then
      return 0
  fi

  if [[ "$cur" == -* ]]; then
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
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi

  return 0
}

function _git_fd() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # shellcheck disable=SC2155
  case "$prev" in
    -e|--ext|-f|--file|-g|--grep|-k|--keyword|-m|--message|--blob) return 0 ;;
    -u|--author) local recent_authors=$( git log -1000 --format="%ae" 2>/dev/null | sort -u )
                 COMPREPLY=( $(compgen -W "$recent_authors" -- "$cur") )
                 return 0 ;;
  esac

  if [[ "$cur" == -* ]]; then
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
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi
}

complete -F _git_mcx git-mcx

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
