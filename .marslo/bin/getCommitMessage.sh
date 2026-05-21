#!/usr/bin/env bash
# shellcheck source=/dev/null
#=============================================================================
#     FileName : getCommitMessage.sh
#       Author : marslo
#      Created : 2025-03-21 01:32:35
#   LastChange : 2026-05-20 22:03:33
#   references : https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit?tab=t.0
#=============================================================================

# |     ENVIRONMENT     |        DESCRIPTION        | DEFAULT |
# |---------------------|---------------------------|---------|
# | MCX_ENABLE_SCOPE    | is enable commit scope    | true    |
# | MCX_LINT_ENABLE     | is enable commit lint     | true    |
# | MCX_ENABLE_BODY     | is enable commit body     | false   |
# | MCX_SHOW_PREVIEW    | is show commit preview    | false   |
# | MCX_SHOW_DIFF       | is show diff after commit | false   |
# | MCX_ENABLE_JIRA     | is enable jira ticket     | false   |
# | MCX_ENABLE_FOOTER   | is enable commit footer   | false   |
# | MCX_BREAKING_CHANGE | is enable breaking change | false   |

set -euo pipefail

# shellcheck disable=SC2155
declare -r CURRENT_DIR="$( dirname "${BASH_SOURCE[0]:-$0}" )"
# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${CURRENT_DIR}/bash-colors.sh" && source "${CURRENT_DIR}/bash-colors.sh" || { c() { :; }; }

declare -a types=(
  "feat:     $(c Wdi)a new feature$(c)"
  "fix:      $(c Wdi)a bug fix$(c)"
  "docs:     $(c Wdi)documentation only changes$(c)"
  "style:    $(c Wdi)changes that do not affect the meaning of the code$(c)"
  "refactor: $(c Wdi)a code change that neither fixes a bug nor adds a feature$(c)"
  "perf:     $(c Wdi)a code change that improves performance$(c)"
  "test:     $(c Wdi)adding missing tests or correcting existing tests$(c)"
  "build:    $(c Wdi)changes that affect the build system or external dependencies$(c)"
  "ci:       $(c Wdi)changes to our CI configuration files and scripts$(c)"
  "chore:    $(c Wdi)other changes that don't modify src or test files$(c)"
  "revert:   $(c Wdi)reverts a previous commit$(c)"
)

function die() { echo -e "$(c Ri)ERROR$(c) $(c Wdi): $*. exit ...$(c)" >&2; exit 1; }

# @usage       : runInteractive <varname> <command string>
# @description : executes a dynamic or piped shell command and assigns its stdout output to a variable.
# @purpose     : in Bash, when a function is called as subshell ( `$(..)` ),
#                the aborts action for interactive commands will in subshell  will not be captured/propagated in parent shell.
# @applicable  : 1. capture the output of dynamic/piped commands
#                2. detect user cancellation or failure in interactive tools
#                3. avoid writing repetitive boilerplate error checking after each fzf/gum
function runInteractive() {
  local __varname=$1
  shift

  local output

  # If one argument and it's a piped string → use eval
  if [[ $# -eq 1 && "$1" == *"|"* ]]; then
    output="$(eval "$1")" || return 130
  else
    output="$("$@")" || return 130
  fi

  printf -v "${__varname}" "%s" "${output}"
}

# @usage       : _rl_read <varname> <prompt>
# @description : readline-safe `read -e` that temporarily disables show-mode-in-prompt
#                so the emacs/vi mode-string won't break multi-line wrapping.
# @explain     : SOH: `\001` - Start of Heading
#                STX: `\002` - Start of Text
#                have `\001` and `\002` surrounding the colorized string to handle multiple lines input
function _rl_read() {
  local __varname="$1"
  local __prompt="$2"
  local __orig
  __orig="$(bind -v 2>/dev/null | command grep 'show-mode-in-prompt')"
  bind 'set show-mode-in-prompt off' 2>/dev/null
  # shellcheck disable=SC2229
  read -rep "$(printf "     \001$(c 0Wdi)\002> \001$(c 0Mi)\002%s\001$(c)\002" "${__prompt}")" "${__varname}"
  bind "${__orig}" 2>/dev/null
}

function selectIssue() {
  local action="${1:-fix}"
  command -v gh >/dev/null 2>&1 || { echo "gh cli not found" >&2; return 1; }
  local issues
  issues=$( gh issue list --state open --limit 100 --json number,title \
              --template '{{range .}}#{{.number}} - {{.title}}{{"\n"}}{{end}}' |
            fzf --multi \
                --ansi \
                --color=fg+:#979736,hl+:#979736 \
                --border \
                --height=15 \
                --prompt="${action} issue > " \
                --info='inline-right: '
          ) || return 130
  [[ -z "${issues}" ]] && return 130
  while IFS= read -r line; do
    echo "${line%% -*}"
  done <<< "${issues}"
}

function getCommitMessage() {
  local jiraId=''

  selected=$( printf "%b\n" "${types[@]}" |
              fzf --no-multi \
                  --ansi \
                  --color=fg+:#979736,hl+:#979736 \
                  --border \
                  --height=12 \
                  --prompt='commit type > ' \
                  --info='inline-right: '
            )
  test -n "${selected}" || exit 1
  type=$(echo "${selected}" | awk -F: '{print $1}')

  if "${MCX_ENABLE_JIRA:-false}"; then
    type -P jira-ls >/dev/null 2>&1 && jiraId=$( jira ls "${JIRA_OPTS[@]}" 2>/dev/null ) || true
    [[ -z "${jiraId}" ]] && _rl_read jiraId 'JIRA ID: '

    jiraId="${jiraId#"${jiraId%%[![:space:]]*}"}"
    jiraId="${jiraId%"${jiraId##*[![:space:]]}"}"
  fi

  if [[ 'true' = "${MCX_ENABLE_SCOPE:-true}" ]]; then
    _rl_read scope 'scope (optional): '
    local -a parts=()
    [[ -n "${jiraId}"     ]] && parts+=("${jiraId}")
    [[ -n "${scope}"      ]] && parts+=("${scope}")
    [[ ${#parts[@]} -gt 0 ]] && scope="($(IFS=,; echo "${parts[*]}"))"
  fi

  _rl_read subject 'commit message subject: '
  test -z "${subject:-}" && exit 1

  if [[ 'true' = "${MCX_ENABLE_BODY:-false}" ]]; then
    runInteractive body gum write --placeholder="commit body (optional)" || return 1
  fi

  local -a footers=()
  if "${MCX_BREAKING_CHANGE:-false}"; then
    if gum confirm "Is this a BREAKING CHANGE?"; then
      local breaking
      runInteractive breaking gum write --placeholder="describe the BREAKING CHANGE" || return 1
      footers+=("BREAKING CHANGE: ${breaking}")
    fi
  fi
  if [[ 'true' = "${MCX_ENABLE_FOOTER:-false}" ]]; then
    case "${_MCX_FOOTER_ACTION:-}" in
      fix | close | resolve )
        local issueIds
        issueIds="$(selectIssue "${_MCX_FOOTER_ACTION}")" || return 1
        local label="${_MCX_FOOTER_ACTION^}ed"
        local ids
        ids="$(paste -sd', ' <<< "${issueIds}")"
        [[ -n "${ids}" ]] && footers+=("${label} ${ids}")
        ;;
      *)
        local _footer
        runInteractive _footer gum input --placeholder="footer (optional -- i.e.: Closes #123)" || return 1
        [[ -n "${_footer}" ]] && footers+=("${_footer}")
        ;;
    esac
  fi

  message="${type}${scope}"
  "${MCX_BREAKING_CHANGE:-false}" && message+='!'
  message+=": ${subject}"
  [[ -n "${body:-}"       ]] && message+=$'\n\n'"${body}"
  [[ ${#footers[@]} -gt 0 ]] && message+=$'\n'
  for f in "${footers[@]}"; do message+=$'\n'"${f}"; done

  echo "${message}"
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
