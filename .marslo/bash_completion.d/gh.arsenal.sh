#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : igh.sh
#       Author : marslo
#      Created : 2026-02-27 23:04:41
#   LastChange : 2026-02-27 23:13:17
#=============================================================================

_gh_ops() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="-c --checkout -C --close -o --open -A --auto-open -s --squash -r --rebase -l --label -S --state -B --base -R --repo -V --verbose --dryrun -h --help"

    case "${prev}" in
        -S|--state)
            COMPREPLY=( $(compgen -W "open closed all merged" -- "${cur}") )
            return 0
            ;;
        -B|--base)
            local branches
            branches=$(git branch --format="%(refname:short)" 2>/dev/null)
            COMPREPLY=( $(compgen -W "${branches}" -- "${cur}") )
            return 0
            ;;
        -l|--label|-R|--repo)
            COMPREPLY=()
            return 0
            ;;
    esac

    for (( i=1; i < COMP_CWORD; i++ )); do
        if [[ "${COMP_WORDS[i]}" == "--" ]]; then
            return 0
        fi
    done

    if [[ ${cur} == -* ]] || [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
        return 0
    fi
}

_gh_new() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="-o --open -V --verbose -a --auto -D --dryrun -h --help"

    for (( i=1; i < COMP_CWORD; i++ )); do
        if [[ "${COMP_WORDS[i]}" == "--" ]]; then
            return 0
        fi
    done

    if [[ ${cur} == -* ]] || [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
        return 0
    fi
}

complete -F _gh_ops gh-ops
complete -F _gh_new gh-new
