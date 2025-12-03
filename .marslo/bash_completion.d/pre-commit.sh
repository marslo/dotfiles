#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2155,SC2207

# ~/.local/share/bash-completion/completions/pre-commit  or  ~/.bash_completion.d/pre-commit
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

  local subcmds="autoupdate clean gc init-templatedir install install-hooks migrate-config run sample-config try-repo uninstall validate-config validate-manifest help hook-impl"
  local global_opts="-h --help -V --version"

  __pc_hook_ids() {
    local cfg
    for cfg in ".pre-commit-config.yaml" ".pre-commit-config.yml" \
               "../.pre-commit-config.yaml" "../.pre-commit-config.yml" \
               "../../.pre-commit-config.yaml" "../../.pre-commit-config.yml"
    do
      [[ -f "$cfg" ]] || continue
      awk '
        $1 ~ /^id:/ {
          sub(/^id:[[:space:]]*/, "", $0)
          gsub(/#.*/, "", $0)
          gsub(/["'\'']/, "", $0)
          gsub(/[[:space:]]+$/, "", $0)
          if (length($0) > 0) print $0
        }
      ' "$cfg" | sort -u
      return 0
    done
  }

  if [[ ${COMP_CWORD} -le 1 ]]; then
    COMPREPLY=( $(compgen -W "${subcmds} ${global_opts}" -- "${cur}") )
    return 0
  fi

  local cmd="${COMP_WORDS[1]}"

  case "${cmd}" in
    run)
      local opts="--all-files --files --hook-stage --color --show-diff-on-failure --config --hook-stage --verbose -v -h --help"
      if [[ "${cur}" != -* ]]; then
        local hooks="$(__pc_hook_ids)"
        if [[ -n "${hooks}" ]]; then
          COMPREPLY=( $(compgen -W "${hooks}" -- "${cur}") )
          return 0
        fi
      fi
      COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
      ;;

    autoupdate)
      COMPREPLY=( $(compgen -W "--bleeding-edge --freeze --repo --from-ref --to-ref -h --help" -- "${cur}") )
      ;;

    install)
      COMPREPLY=( $(compgen -W "--hook-type --install-hooks --overwrite -f --config -h --help" -- "${cur}") )
      ;;

    install-hooks)
      COMPREPLY=( $(compgen -W "--config -h --help" -- "${cur}") )
      ;;

    try-repo)
      if [[ ${COMP_CWORD} -ge 2 && "${cur}" != -* ]]; then
        COMPREPLY=( $(compgen -o plusdirs -f -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "--ref --hook --verbose -v -h --help" -- "${cur}") )
      fi
      ;;

    validate-config|validate-manifest|gc|clean|migrate-config|sample-config|uninstall|init-templatedir|help|hook-impl)
      COMPREPLY=( $(compgen -W "-h --help" -- "${cur}") )
      ;;

    *)
      COMPREPLY=( $(compgen -W "${subcmds} ${global_opts}" -- "${cur}") )
      ;;
  esac
}
complete -F _pre_commit pre-commit

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
