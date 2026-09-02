#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2155,SC2207
#=============================================================================
#     FileName : pre-commit.sh
#       Author : marslo
#      Created : 2025-11-07 11:40:52
#   LastChange : 2026-05-13 14:45:06
#=============================================================================

# ~/.local/share/bash-completion/completions/pre-commit or ~/.bash_completion.d/pre-commit
# bash completion for pre-commit
_pre_commit() {
  local cur prev words cword
  if declare -F _init_completion >/dev/null 2>&1; then
    _init_completion -n : || return
  else
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  local subcmds='autoupdate clean gc init-templatedir install install-hooks migrate-config run sample-config try-repo uninstall validate-config validate-manifest help hook-impl'
  local global_opts='-h --help -V --version'
  # `install -t/--hook-type` accepts these git hook types; `run --hook-stage` accepts the same plus `manual`
  local hook_types='commit-msg post-checkout post-commit post-merge post-rewrite pre-commit pre-merge-commit pre-push pre-rebase prepare-commit-msg'
  local hook_stages="${hook_types} manual"

  __pc_hook_ids() {
    local cfg
    for cfg in '.pre-commit-config.yaml' '.pre-commit-config.yml' \
               '../.pre-commit-config.yaml' '../.pre-commit-config.yml' \
               '../../.pre-commit-config.yaml' '../../.pre-commit-config.yml'
    do
      [[ -f "${cfg}" ]] || continue
      awk '
        /^[[:space:]]*-?[[:space:]]*id:[[:space:]]*/ {
          line = $0
          sub(/^[[:space:]]*-?[[:space:]]*id:[[:space:]]*/, "", line)
          gsub(/#.*/, "", line)
          gsub(/["'\'']/, "", line)
          gsub(/[[:space:]]+$/, "", line)
          if (length(line) > 0) print line
        }
      ' "${cfg}" | sort -u
      return 0
    done
  }

  if [[ ${COMP_CWORD} -le 1 ]]; then
    COMPREPLY=( $(compgen -W "${subcmds} ${global_opts}" -- "${cur}") )
    return 0
  fi

  local cmd="${COMP_WORDS[1]}"

  # value completion for options shared across subcommands
  case "${prev}" in
    --color        ) COMPREPLY=( $(compgen -W "auto always never" -- "${cur}") ); return 0 ;;
    -c|--config    ) COMPREPLY=( $(compgen -f -- "${cur}") )                    ; return 0 ;;
    -t|--hook-type ) COMPREPLY=( $(compgen -W "${hook_types}" -- "${cur}") )    ; return 0 ;;
  esac

  case "${cmd}" in
    run)
      case "${prev}" in
        --hook-stage ) COMPREPLY=( $(compgen -W "${hook_stages}" -- "${cur}") ); return 0 ;;
        --files      ) COMPREPLY=( $(compgen -f -- "${cur}") )                 ; return 0 ;;
      esac
      local opts="--all-files --files --hook-stage --color --show-diff-on-failure --config --verbose -v -h --help"
      if [[ "${cur}" != -* ]]; then
        local hooks="$(__pc_hook_ids)"
        if [[ -n "${hooks}" ]]; then
          COMPREPLY=( $(compgen -W "${hooks}" -- "${cur}") )
          return 0
        fi
      fi
      COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
      ;;

    install)
      COMPREPLY=( $(compgen -W "-t --hook-type --install-hooks -f --overwrite -c --config --allow-missing-config --color -h --help" -- "${cur}") )
      ;;

    install-hooks)
      COMPREPLY=( $(compgen -W "-c --config --color -h --help" -- "${cur}") )
      ;;

    uninstall)
      COMPREPLY=( $(compgen -W "-t --hook-type -c --config --color -h --help" -- "${cur}") )
      ;;

    init-templatedir)
      [[ "${cur}" != -* ]] && { COMPREPLY=( $(compgen -d -- "${cur}") ); return 0; }
      COMPREPLY=( $(compgen -W "-t --hook-type -c --config --no-allow-missing-config --color -h --help" -- "${cur}") )
      ;;

    autoupdate)
      case "${prev}" in
        --repo | -j | --jobs ) return 0 ;;
      esac
      COMPREPLY=( $(compgen -W "--bleeding-edge --freeze --repo -j --jobs -c --config --color -h --help" -- "${cur}") )
      ;;

    hook-impl)
      case "${prev}" in
        --hook-dir ) COMPREPLY=( $(compgen -d -- "${cur}") ); return 0 ;;
      esac
      COMPREPLY=( $(compgen -W "--color -c --config --hook-type --hook-dir --skip-on-missing-config -h --help" -- "${cur}") )
      ;;

    try-repo)
      if [[ ${COMP_CWORD} -ge 2 && "${cur}" != -* ]]; then
        COMPREPLY=( $(compgen -o plusdirs -f -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "--ref --hook --verbose -v --color -h --help" -- "${cur}") )
      fi
      ;;

    migrate-config)
      COMPREPLY=( $(compgen -W "-c --config --color -h --help" -- "${cur}") )
      ;;

    validate-config|validate-manifest)
      [[ "${cur}" != -* ]] && { COMPREPLY=( $(compgen -f -- "${cur}") ); return 0; }
      COMPREPLY=( $(compgen -W "--color -h --help" -- "${cur}") )
      ;;

    sample-config|gc|clean)
      COMPREPLY=( $(compgen -W "--color -h --help" -- "${cur}") )
      ;;

    help)
      COMPREPLY=( $(compgen -W "${subcmds}" -- "${cur}") )
      ;;

    *)
      COMPREPLY=( $(compgen -W "${subcmds} ${global_opts}" -- "${cur}") )
      ;;
  esac
}
complete -F _pre_commit pre-commit

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
