#!/usr/bin/env bash
# shellcheck source=/dev/null
#=============================================================================
#     FileName : getCommitMessage.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-03-21 01:32:35
#   LastChange : 2025-10-10 18:37:50
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
declare -r BIN_DIR="$( dirname "${BASH_SOURCE[0]:-$0}" )"
# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${BIN_DIR}/bash-colors.sh" && source "${BIN_DIR}/bash-colors.sh" || { c() { :; }; }

types=(
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

  printf -v "$__varname" "%s" "$output"
}

# SOH: `\001` - Start of Heading
# STX: `\002` - Start of Text
# have `\001` and `\002` surrounding the colorized string to handle multiple lines input
function getCommitMessage() {
  declare jiraId=''
  if [[ 'true' = "${MCX_ENABLE_JIRA:-false}" ]]; then
    read -rep "$(printf "\001$(c Mi)\002%s\001$(c)\002" 'JIRA ID: ')" jiraId
  fi

  selected=$( printf "%b\n" "${types[@]}" |
              fzf --prompt="commit type: " --height=10 --border --ansi --color=fg+:#979736,hl+:#979736
            )
  [[ -n "${selected}" ]] || die 'no commit type selected'
  type=$(echo "${selected}" | awk -F: '{print $1}')

  if [[ 'true' = "${MCX_ENABLE_SCOPE:-true}" ]]; then
    read -rep "$(printf "\001$(c Mi)\002%s\001$(c)\002" 'scope (optional): ')" scope
    local -a parts=()
    [[ -n "${jiraId}"     ]] && parts+=("${jiraId}")
    [[ -n "${scope}"      ]] && parts+=("${scope}")
    [[ ${#parts[@]} -gt 0 ]] && scope="($(IFS=,; echo "${parts[*]}"))"
  fi

  read -rep "$(printf "\001$(c Mi)\002%s\001$(c)\002" 'commit message subject: ')" subject
  [[ -z "${subject}" ]] && die 'no commit subject entered'

  if [[ 'true' = "${MCX_ENABLE_BODY:-false}" ]]; then
    runInteractive body gum write --placeholder="commit body (optional)" || return 1
  fi

  declare breaking=''
  declare bfooter=''
  if "${MCX_BREAKING_CHANGE:-false}"; then
    if gum confirm "Is this a BREAKING CHANGE?"; then
      runInteractive breaking gum write --placeholder="describe the BREAKING CHANGE" || return 1
      bfooter="BREAKING CHANGE: ${breaking}"
    fi
  fi

  declare footer=''
  if [[ 'true' = "${MCX_ENABLE_FOOTER:-false}" ]]; then
    runInteractive footer gum input --placeholder="footer (optional -- i.e.: Closes #123)" || return 1
  fi

  message="${type}${scope}"
  "${MCX_BREAKING_CHANGE:-false}" && message+='!'
  message+=": ${subject}"
  [[ -n "${body:-}"    ]] && message+=$'\n\n'"${body}"
  [[ -n "${bfooter}" || "${footer:-}" ]] && message+=$'\n'
  [[ -n "${bfooter:-}" ]] && message+=$'\n'"${bfooter}"
  [[ -n "${footer:-}"  ]] && message+=$'\n'"${footer}"

  echo "${message}"
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
