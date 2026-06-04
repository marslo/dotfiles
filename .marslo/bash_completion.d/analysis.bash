#!/usr/bin/env bash
# shellcheck disable=SC2207
# =============================================================================
#      FileName : completion.bash
#        Author : marslo
#       Created : 2026-06-02 16:21:45
#    LastChange : 2026-06-03 01:13:01
# =============================================================================

function _analysis() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="-i --input -o --output -j --job -b --build --url -t --theme -m --model -h --help"

  local models=(
    auto
    composer-2.5
    claude-opus-4-8-thinking-high
    gpt-5.5-high
    gpt-5.4-high
    claude-4.6-opus-high-thinking
    claude-opus-4-8-low
    claude-opus-4-8-medium
    claude-opus-4-8-high
    claude-opus-4-8-xhigh
    claude-opus-4-8-max
    claude-opus-4-8-thinking-low
    claude-opus-4-8-thinking-medium
    claude-opus-4-8-thinking-xhigh
    claude-opus-4-8-thinking-max
    gpt-5.5-none
    gpt-5.5-low
    gpt-5.5-medium
    gpt-5.5-extra-high
    claude-4.6-sonnet-medium
    claude-4.6-sonnet-medium-thinking
    gpt-5.4-low
    gpt-5.4-medium
    gpt-5.4-xhigh
    claude-4.6-opus-high
    claude-4.6-opus-max
    claude-4.6-opus-max-thinking
    gemini-3.1-pro
    gpt-5.4-mini-none
    gpt-5.4-mini-low
    gpt-5.4-mini-medium
    gpt-5.4-mini-high
    gpt-5.4-mini-xhigh
    gpt-5.4-nano-none
    gpt-5.4-nano-low
    gpt-5.4-nano-medium
    gpt-5.4-nano-high
    gpt-5.4-nano-xhigh
    gemini-3-flash
    gemini-3.5-flash
  )

  case "${prev}" in
    -i | --input  ) COMPREPLY=( $(compgen -f -- "${cur}") ); compopt -o filenames; return ;;
    -o | --output ) COMPREPLY=( $(compgen -f -- "${cur}") ); compopt -o filenames; return ;;
    -t | --theme  ) COMPREPLY=( $(compgen -W "light dark" -- "${cur}") ); return ;;
    -m | --model  ) COMPREPLY=( $(compgen -W "${models[*]}" -- "${cur}") ); return ;;
  esac

  # --key=value style
  if [[ "${cur}" == --input=* ]]; then
    COMPREPLY=( $(compgen -f -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/--input=}" )
    compopt -o filenames
    return
  elif [[ "${cur}" == --output=* ]]; then
    COMPREPLY=( $(compgen -f -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/--output=}" )
    compopt -o filenames
    return
  elif [[ "${cur}" == --theme=* ]]; then
    COMPREPLY=( $(compgen -W "light dark" -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/--theme=}" )
    return
  elif [[ "${cur}" == --model=* ]]; then
    COMPREPLY=( $(compgen -W "${models[*]}" -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/--model=}" )
    return
  fi

  COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}

# bash completion for jdownload.sh

function _jdownload() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="-j --job -b --build -p --path -h --help"

  case "${prev}" in
    -p | --path  ) COMPREPLY=( $(compgen -d -- "${cur}" )  )
                   compopt -o filenames
                   return ;;
  esac

  if [[ "${cur}" == --path=* ]]; then
    COMPREPLY=( $(compgen -d -- "${cur#*=}") )
    COMPREPLY=( "${COMPREPLY[@]/#/--path=}" )
    compopt -o filenames
    return
  fi

  COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}

complete -o bashdefault -o default -F _analysis  analysis.sh
complete -o bashdefault -o default -F _analysis  ./analysis.sh
complete -o bashdefault -o default -F _jdownload jdownload.sh
complete -o bashdefault -o default -F _jdownload ./jdownload.sh

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
