#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : imarslo.sh
#       Author : marslo
#      Created : 2026-03-09 14:28:06
#   LastChange : 2026-03-12 18:13:26
#=============================================================================

_compgen_nocase() {
  local cur="$1"
  local candidates="$2"
  local word

  # clear the array before each call
  COMPREPLY=()

  for word in ${candidates}; do
    # convert both word and cur to lowercase for case-insensitive comparison
    if [[ "${word,,}" == "${cur,,}"* ]]; then
      COMPREPLY+=( "$word" )
    fi
  done
}

function _hex2rgba_completion() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="-a --alpha -b --background -h --help"

  case "${prev}" in
    # alpha: 0.0 - 1.0
    -a|--alpha      ) COMPREPLY=( $(compgen -W "0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0" -- "$cur") ); return 0 ;;
    # background color suggestions: hex with #, rgb with commas
    -b|--background ) COMPREPLY=( $(compgen -W "'#FFFFFF' '#000000' 255,255,255 0,0,0" -- "$cur") ); return 0 ;;
    -h|--help       ) return 0 ;;
  esac

  # if starts with `-`, suggest options
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
    return 0
  fi
}

function _rgba2hex_completion() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="-a --alpha -b --background -h --help"

  case "$prev" in
    -a|--alpha)
        COMPREPLY=( $(compgen -W "0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0" -- "$cur") )
        return 0
        ;;
    # rgba2hex background color default is 255,255,255
    -b|--background)
        COMPREPLY=( $(compgen -W "255,255,255 0,0,0 #FFFFFF #000000 255" -- "$cur") )
        return 0
        ;;
  esac

  # complete options if current word starts with -
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi

  if [[ "$cur" == "r"* ]]; then
    COMPREPLY=( $(compgen -W "rgba( rgb(" -- "$cur") )
    return 0
  fi
}

_JIRA_STAT_OPTS="-p --project -t --type -c --condition -a --and -o --or -m --max -j --jql -i --index -h --help -v -vv --verbose"
_JIRA_LS_OPTS="--new --in-progress --todo --open --closed --reporter --assignee -p --project -u --update -r --return -h --help"
_JIRA_STAT_CONDITIONS="AND OR IN"

function _jira_stat_logic() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "${prev}" in
    -c|--condition ) _compgen_nocase "${cur}" "${_JIRA_STAT_CONDITIONS}"; return 0 ;;
    -p|--project|-t|--type|-m|--max|-j|--jql ) return 0 ;;
  esac

  COMPREPLY=( $(compgen -W "${_JIRA_STAT_OPTS}" -- "${cur}") )
}

function _jira_ls_logic() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "${prev}" in
    -p|--project ) _compgen_nocase "${cur}" "IPBUSW IPBD SPTA"; return 0 ;;
    -r|--return  ) _compgen_nocase "${cur}" "full short"; return 0 ;;
    --assignee|--reporter ) _compgen_nocase "${cur}" "'currentUser()' unassigned"; return 0 ;;
  esac

  COMPREPLY=( $(compgen -W "${_JIRA_LS_OPTS}" -- "${cur}") )
}

function _jira_completions() {
  local cur prev subcommands
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  subcommands="ls stat help"

  # sub-commands completion
  if [[ ${COMP_CWORD} -eq 1 ]] ; then
    COMPREPLY=( $(compgen -W "${subcommands}" -- "${cur}") )
    return 0
  fi

  # find the current sub-command
  local cmd=''
  for i in "${!COMP_WORDS[@]}"; do
    if [[ $i -gt 0 && " ${subcommands} " == *" ${COMP_WORDS[$i]} "* ]]; then
      cmd="${COMP_WORDS[$i]}"; break;
    fi
  done

  case "${cmd}" in
      stat ) _jira_stat_logic ;;
      ls   ) _jira_ls_logic   ;;
      help ) COMPREPLY=( $(compgen -W "${subcommands//help/}" -- "${cur}") ); return 0 ;;
  esac
}

function _jira_stat_completions() { _jira_stat_logic; }
function _jira_ls_completions() { _jira_ls_logic; }

function _gdoc_completion() {
  local cur prev opts re_projects sms_projects

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="--re --sms -l --local -v --verbose -h --help"

  re_projects="release-engineering"
  sms_projects="common util wukong vega exerciser nevox zao lion alpine"

  case "${prev}" in
      --re  ) COMPREPLY=( $(compgen -W "${re_projects}" -- "${cur}")  ); return 0 ;;
      --sms ) COMPREPLY=( $(compgen -W "${sms_projects}" -- "${cur}") ); return 0 ;;
      *     ) ;;
  esac

  if [[ "${cur}" == -* ]] ; then
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  fi
}

complete -F _jira_completions      jira
complete -F _jira_stat_completions jira-stat
complete -F _jira_ls_completions   jira-ls
complete -F _hex2rgba_completion   hex2rgba
complete -F _rgba2hex_completion   rgba2hex
complete -F _gdoc_completion       gdoc

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
