#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : typos-msg.bash
#       Author : marslo
#      Created : 2026-09-01 23:40:00
#   LastChange : 2026-09-01 23:40:00
#=============================================================================

# bash completion for typos-msg
_typos_msg() {
  local cur prev i repoDir='.'
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local opts='--hook --cli --fix --repo -m -h --help'

  # honor a --repo <dir> already on the line, so <ref> completion targets that repo
  for (( i=1; i < COMP_CWORD; i++ )); do
    [[ "${COMP_WORDS[i]}" == '--repo' ]] && repoDir="${COMP_WORDS[i+1]:-.}"
  done

  case "${prev}" in
    --repo ) COMPREPLY=( $(compgen -d -- "${cur}") ); return 0 ;;   # a directory
    -m     ) return 0 ;;                                            # free text, no completion
  esac

  if [[ "${cur}" == -* ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi

  # otherwise: a git <ref> in the target repo (branches, tags, HEAD)
  local refs
  refs="$( git -C "${repoDir}" for-each-ref --format='%(refname:short)' refs/heads refs/tags 2>/dev/null )"
  COMPREPLY=( $(compgen -W "${refs} HEAD" -- "${cur}") )
}
complete -o bashdefault -o default -F _typos_msg typos-msg

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
