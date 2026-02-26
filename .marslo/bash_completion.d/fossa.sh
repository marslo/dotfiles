#!/bin/bash

_fossa_completions()
{
    local cur prev words cword
    _init_completion || return

    local commands="analyze test report container list-targets experimental-link-user-defined-dependency-binary sbom init feedback project release-group"

    local global_opts="-h --help -V --version"

    local analyze_opts="--detect-vendored --debug"
    local report_opts="--format attribution"

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands} ${global_opts}" -- "${cur}") )
        return 0
    fi

    case "${prev}" in
        analyze)
            COMPREPLY=( $(compgen -W "${analyze_opts}" -- "${cur}") )
            _filedir
            return 0
            ;;
        report)
            COMPREPLY=( $(compgen -W "${report_opts}" -- "${cur}") )
            return 0
            ;;
        --format)
            COMPREPLY=( $(compgen -W "html json" -- "${cur}") )
            return 0
            ;;
        test|container|sbom|init)
            _filedir
            return 0
            ;;
        *)
            ;;
    esac

    return 0
}

complete -F _fossa_completions fossa
