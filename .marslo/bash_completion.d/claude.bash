#!/usr/bin/env bash
# shellcheck disable=SC2207
# =============================================================================
#      FileName : claude.bash
#        Author : marslo
#       Created : 2026-07-09 17:52:49
#    LastChange : 2026-07-09 17:59:00
#   Description : created base on help message for claude 2.1.205
# =============================================================================

function _compgen_nocase() {
  local cur="$1"
  local candidates="$2"
  local word

  # clear the array before each call
  COMPREPLY=()

  for word in ${candidates}; do
    # convert both word and cur to lowercase for case-insensitive comparison
    if [[ "${word,,}" == "${cur,,}"* ]]; then
      COMPREPLY+=( "${word}" )
    fi
  done
}

function _claude() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # value completion for options that expect an argument
  case "${prev}" in
    --effort                 ) _compgen_nocase "${cur}" "low medium high xhigh max"; return 0 ;;
    --output-format          ) _compgen_nocase "${cur}" "text json stream-json"; return 0 ;;
    --input-format           ) _compgen_nocase "${cur}" "text stream-json"; return 0 ;;
    --permission-mode        ) _compgen_nocase "${cur}" "acceptEdits auto bypassPermissions manual dontAsk plan"; return 0 ;;
    --model|--fallback-model ) _compgen_nocase "${cur}" "opus sonnet haiku fable"; return 0 ;;
    --prompt-suggestions     ) _compgen_nocase "${cur}" "true false 1 0 yes no on off"; return 0 ;;
    --setting-sources        ) _compgen_nocase "${cur}" "user project local"; return 0 ;;
    --tmux                   ) _compgen_nocase "${cur}" "classic"; return 0 ;;
    --add-dir|--plugin-dir   ) _claude_filedir -d; return 0 ;;
    --debug-file|--settings|--mcp-config|--file|--json-schema|--append-system-prompt-file|--system-prompt-file )
                                  _claude_filedir; return 0 ;;
    # options that take a free-form value we can't usefully complete
    --agent|--agents|--append-system-prompt|--system-prompt|--betas|-n|--name| \
    --max-budget-usd|--session-id|--from-pr|-r|--resume|--remote-control| \
    --remote-control-session-name-prefix|--plugin-url|--tools|--allowedTools| \
    --allowed-tools|--disallowedTools|--disallowed-tools|-d|--debug ) return 0 ;;
  esac

  # complete option flags
  if [[ "${cur}" == -* ]]; then
    COMPREPLY=( $(compgen -W "${_CLAUDE_OPTS}" -- "${cur}") )
    return 0
  fi

  # offer sub-commands as the first non-option word
  local w seen_sub='false'
  for w in "${COMP_WORDS[@]:1:COMP_CWORD-1}"; do
    if [[ " ${_CLAUDE_SUBCOMMANDS} " == *" ${w} "* ]]; then seen_sub='true'; break; fi
  done
  [[ "${seen_sub}" == 'false' ]] && COMPREPLY=( $(compgen -W "${_CLAUDE_SUBCOMMANDS}" -- "${cur}") )
}

complete -o default -o bashdefault -F _claude claude

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
