#!/usr/bin/env bash

_extractor_completion() {
  local cur file

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # 1. complete the first parameter (file path).
  if [[ ${COMP_CWORD} -eq 1 ]]; then
    # use `compgen -f` to trigger the default file/directory auto-completion.
    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -f -- "${cur}") )
    type compopt &>/dev/null && compopt -o filenames
    return 0
  fi

  # 2. complete the second parameter (function name).
  file="${COMP_WORDS[1]}";
  file="${file/#\~/$HOME}"
  [[ -f "${file}" ]] || return 0;
  local funcs;
  funcs=$(awk '
    /^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{/ {
      sub(/^[[:space:]]*/, "")
      sub(/^function[[:space:]]+/, "")
      sub(/[[:space:]]*\(\).*$/, "")
      print
    }
  ' "${file}");

  # shellcheck disable=SC2207
  COMPREPLY=( $(compgen -W "${funcs}" -- "${cur}") )
}

complete -F _extractor_completion extractor
