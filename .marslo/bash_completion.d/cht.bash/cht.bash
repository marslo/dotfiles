#!/usr/bin/env bash
# =============================================================================
#      FileName : cht.bash
#        Author : marslo
#       Created : 2024-01-06 04:26:44
#    LastChange : 2026-10-26 18:34:17
# =============================================================================

_cht_complete() {
    local cur prev opts
    _get_comp_words_by_ref -n : cur

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    # shellcheck disable=SC2034
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    # opts="$(curl -s cheat.sh/:list)"
    opts="$(command cat "$HOME"/.marslo/bash_completion.d/cht.bash/cht.bash.txt)"

    if [ "${COMP_CWORD}" = 1 ]; then
    mapfile -t COMPREPLY < <( compgen -W "${opts}" -- "${cur}" )
    __ltrim_colon_completions "${cur}"
    fi
    return 0
}
complete -F _cht_complete cht.sh

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
