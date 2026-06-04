#!/usr/bin/env bash
# shellcheck disable=SC2207,SC2034

# bash completion for cursor-agent
# source this file from your ~/.bashrc:
#   source ~/.cursor/cursor-agent-completion.bash

function _cursor_agent_models() {
  # cache model list for the shell session to avoid repeated CLI calls
  if [[ -z "${_CURSOR_AGENT_MODELS_CACHE:-}" ]]; then
    # strip ANSI color codes, then keep only "<id> - <description>" lines
    _CURSOR_AGENT_MODELS_CACHE="$(cursor-agent --list-models 2>/dev/null \
      | sed -E $'s/\x1b\\[[0-9;]*m//g' \
      | sed -nE 's/^([A-Za-z0-9._-]+) - .*/\1/p')"
  fi
  printf '%s\n' "$_CURSOR_AGENT_MODELS_CACHE"
}

function _cursor_agent() {
  local cur prev words cword
  _init_completion 2>/dev/null || {
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  }

  local subcommands="install-shell-integration uninstall-shell-integration \
                     login logout mcp worker status whoami models about update create-chat \
                     generate-rule rule agent ls resume help"

  local opts="-v --version --api-key -H --header -p --print --output-format \
              --stream-partial-output --mode --plan --resume --continue --model \
              --list-models -f --force --yolo --sandbox --approve-mcps --trust --workspace \
              --plugin-dir -w --worktree --worktree-base --skip-worktree-setup -h --help"

  # complete the value for options that take an argument
  case "${prev}" in
    --model)
      COMPREPLY=( $(compgen -W "$(_cursor_agent_models)" -- "${cur}") )
      return 0
      ;;
    --mode)
      COMPREPLY=( $(compgen -W "plan ask" -- "${cur}") )
      return 0
      ;;
    --output-format)
      COMPREPLY=( $(compgen -W "text json stream-json" -- "${cur}") )
      return 0
      ;;
    --sandbox)
      COMPREPLY=( $(compgen -W "enabled disabled" -- "${cur}") )
      return 0
      ;;
    --workspace|--plugin-dir|-w|--worktree)
      COMPREPLY=( $(compgen -d -- "${cur}") )
      return 0
      ;;
    --api-key|-H|--header|--worktree-base)
      # free-form value, no completion
      return 0
      ;;
  esac

  # flags
  if [[ "${cur}" == -* ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi

  # first non-option word -> subcommand
  local i seen_sub=0
  for (( i=1; i < COMP_CWORD; i++ )); do
    [[ "${COMP_WORDS[i]}" != -* ]] && { seen_sub=1; break; }
  done
  if [[ $seen_sub -eq 0 ]]; then
    COMPREPLY=( $(compgen -W "${subcommands}" -- "${cur}") )
    return 0
  fi
}

complete -o bashdefault -o default -F _cursor_agent cursor-agent
complete -o bashdefault -o default -F _cursor_agent agent

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
