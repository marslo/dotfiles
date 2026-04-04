#!/usr/bin/env bash
# shellcheck disable=SC2207

function _mas() {
  local cur cword

  if declare -F _init_completion >/dev/null 2>&1; then
    _init_completion
  else
    COMPREPLY=()
    _get_comp_words_by_ref cur prev words cword
  fi

  if [[ "${cword}" -eq 1 ]]; then
    local -a helps

    mapfile -t helps < <( mas help 2>/dev/null )
    local -a commands=(help -h --version)

    for line in "${helps[@]}"; do
      if [[ "${line}" =~ ^[[:space:]]+([^:].*) ]]; then
        local full_text="${BASH_REMATCH[1]}"
        local cmd_part="${full_text%%  *}"

        if [[ "$cmd_part" != "$full_text" ]]; then
          commands+=("$cmd_part")
        fi
      fi
    done

    # remove , and replace with space
    local cmd_string="${commands[*]//,/ }"

    COMPREPLY=( $(compgen -W "${cmd_string}" -- "${cur}") )
    return 0
  fi
}

complete -F _mas mas

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
