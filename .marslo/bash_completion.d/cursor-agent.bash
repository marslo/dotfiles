#!/usr/bin/env bash
# shellcheck disable=SC2207,SC2034,SC2199,SC2145
# =============================================================================
#      FileName : cursor-agent.bash
#        Author : marslo
#       Created : 2026-06-03 18:05:11
#    LastChange : 2026-08-03 16:55:00
# =============================================================================
# bash completion for cursor-agent / agent
# source this file from your ~/.bashrc:
#   source ~/.marslo/bash_completion.d/cursor-agent.bash

# cache model ids for the shell session; strip ANSI, keep "<id> - <desc>" lines
function _cursor_agent_models() {
  local bin="${1:-cursor-agent}"
  if [[ -z "${_CURSOR_AGENT_MODELS_CACHE:-}" ]]; then
    _CURSOR_AGENT_MODELS_CACHE="$("${bin}" --list-models 2>/dev/null \
      | sed -E $'s/\x1b\\[[0-9;]*m//g' \
      | sed -nE 's/^([A-Za-z0-9._-]+) - .*/\1/p')"
  fi
  printf '%s\n' "${_CURSOR_AGENT_MODELS_CACHE}"
}

# mcpServers keys from project + user mcp.json (relative to CWD like the CLI); jq then python3
function _cursor_agent_mcp_servers() {
  local f
  for f in ".cursor/mcp.json" "${HOME}/.cursor/mcp.json"; do
    [[ -f "${f}" ]] || continue
    if command -v jq >/dev/null 2>&1; then
      jq -r '.mcpServers // {} | keys[]' "${f}" 2>/dev/null
    elif command -v python3 >/dev/null 2>&1; then
      python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])); print("\n".join((d.get("mcpServers") or {}).keys()))
except Exception: pass' "${f}" 2>/dev/null
    fi
  done | awk 'NF' | sort -u
}

function _cursor_agent() {
  local cur prev words cword
  _init_completion 2>/dev/null || {
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=( "${COMP_WORDS[@]}" )
    cword=${COMP_CWORD}
  }

  local bin="${words[0]:-cursor-agent}"

  # root/global options (before a subcommand)
  local global_opts="-v --version --api-key -H --header -e --endpoint -p --print \
    --output-format --stream-partial-output --mode --plan --resume --continue \
    --model --list-models -f --force --yolo --auto-review --sandbox --approve-mcps \
    --trust --workspace --add-dir --plugin-dir -w --worktree --worktree-base \
    --skip-worktree-setup -h --help"

  local top_cmds="install-shell-integration uninstall-shell-integration login \
    logout mcp plugin worker status whoami models bedrock about update create-chat \
    generate-rule rule agent ls resume help"

  # options that consume the NEXT word as their value (used to skip values in path scan)
  local opts_with_arg="--api-key -H --header -e --endpoint --output-format --mode \
    --model --sandbox --workspace --add-dir --plugin-dir --worktree-base --format \
    --auth-token-file --worker-dir --management-addr --label --labels-file \
    --idle-release-timeout --pool-name --name --data-dir --access-key --secret-key \
    --region --test-model"

  # 1) value completion for the option in $prev
  case "${prev}" in
    --model)         COMPREPLY=( $(compgen -W "$(_cursor_agent_models "${bin}")" -- "${cur}") ); return 0 ;;
    --mode)          COMPREPLY=( $(compgen -W "plan ask" -- "${cur}") ); return 0 ;;
    --output-format) COMPREPLY=( $(compgen -W "text json stream-json" -- "${cur}") ); return 0 ;;
    --sandbox)       COMPREPLY=( $(compgen -W "enabled disabled" -- "${cur}") ); return 0 ;;
    --format)        COMPREPLY=( $(compgen -W "text json" -- "${cur}") ); return 0 ;;
    --workspace|--add-dir|--plugin-dir|-w|--worktree|--worker-dir|--data-dir)
                     compopt -o filenames 2>/dev/null
                     COMPREPLY=( $(compgen -d -- "${cur}") ); return 0 ;;
    --auth-token-file|--labels-file)
                     compopt -o filenames 2>/dev/null
                     COMPREPLY=( $(compgen -f -- "${cur}") ); return 0 ;;
    --api-key|-H|--header|-e|--endpoint|--worktree-base|--management-addr|--label|\
    --idle-release-timeout|--pool-name|--name|--access-key|--secret-key|--region|--test-model)
                     return 0 ;;   # freeform value, no completion
  esac

  # 2) command path: non-flag tokens, skipping option values
  local path=() i w skip=0
  for (( i=1; i < cword; i++ )); do
    w="${words[i]}"
    if (( skip )); then skip=0; continue; fi
    if [[ "${w}" == -* ]]; then
      case " ${opts_with_arg} " in *" ${w} "*) skip=1 ;; esac
      continue
    fi
    path+=( "${w}" )
  done
  local cmd="${path[*]}"

  # 3) dispatch by command path
  case "${cmd}" in
    "")
      if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "${global_opts}" -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "${top_cmds}" -- "${cur}") )
      fi
      ;;

    mcp)
      if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-h --help" -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "login list list-tools enable disable" -- "${cur}") )
      fi
      ;;
    "mcp login"|"mcp list-tools"|"mcp enable"|"mcp disable")
      local IFS=$'\n'
      COMPREPLY=( $(compgen -W "$(_cursor_agent_mcp_servers)" -- "${cur}") )
      ;;

    plugin)
      if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-h --help" -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "marketplace" -- "${cur}") )
      fi
      ;;
    "plugin marketplace")
      if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-h --help" -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "add list remove update" -- "${cur}") )
      fi
      ;;

    worker)
      if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "--auth-token-file --worker-dir --management-addr \
          --label --labels-file --idle-release-timeout --pool --single-use \
          --pool-name --name --data-dir --debug -h --help" -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "start debug help" -- "${cur}") )
      fi
      ;;
    "worker start")
      [[ "${cur}" == -* ]] && COMPREPLY=( $(compgen -W "--verbose -h --help" -- "${cur}") )
      ;;
    "worker debug")
      [[ "${cur}" == -* ]] && COMPREPLY=( $(compgen -W "--json -h --help" -- "${cur}") )
      ;;

    bedrock)
      if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-h --help" -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "configure enable status test clear disable help" -- "${cur}") )
      fi
      ;;
    "bedrock configure")
      [[ "${cur}" == -* ]] && COMPREPLY=( $(compgen -W "--access-key --secret-key \
        --from-env --region --test-model -h --help" -- "${cur}") )
      ;;

    status|whoami|about)
      [[ "${cur}" == -* ]] && COMPREPLY=( $(compgen -W "--format -h --help" -- "${cur}") )
      ;;

    help)
      COMPREPLY=( $(compgen -W "${top_cmds}" -- "${cur}") )
      ;;

    agent)
      # nested `agent agent [prompt...]`: mirror root options only
      [[ "${cur}" == -* ]] && COMPREPLY=( $(compgen -W "${global_opts}" -- "${cur}") )
      ;;

    *)
      # leaf commands (login/logout/models/ls/resume/update/create-chat/rule/...): help only
      [[ "${cur}" == -* ]] && COMPREPLY=( $(compgen -W "-h --help" -- "${cur}") )
      ;;
  esac
}

complete -F _cursor_agent cursor-agent
complete -F _cursor_agent agent

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
