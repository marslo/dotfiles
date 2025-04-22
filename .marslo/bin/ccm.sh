#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2155
#=============================================================================
#     FileName : ccm.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-03-21 03:34:24
#   LastChange : 2025-04-22 00:29:48
#  Description : ccm - [c]hatgpt [c]ommit [m]essage generator
#                +----------------------+--------------------+------------+
#                | ENVIRONMENT VARIABLE | DEFAULT VALUE      | NOTES      |
#                +----------------------+--------------------+------------+
#                | MCX_MODEL            | gpt-4-1106-preview | -          |
#                | MCX_TEMPERATURE      | 0.3                | -          |
#                | OPENAI_API_KEY       | env.OPENAI_API_KEY | mandatory* |
#                +----------------------+--------------------+------------+
#=============================================================================

# OpenAI Models:
# +----------------------------+------------------+
# | MODEL NAME                 | CONTEXT (TOKENS) +
# +----------------------------+------------------+
# | gpt-3.5-turbo              | 4,096            |
# | gpt-3.5-turbo-16k          | 16,384           |
# | gpt-4                      | 8,192            |
# | gpt-4-turbo                | 128,000          |
# | gpt-4-1106-preview         | 128,000          |
# | gpt-4.5-preview            | 128,000          |
# | gpt-4.5-preview-2025-02-27 | 128,000          |
# | gpt-4o                     | 128,000          |
# | gpt-4o-mini                | 128,000          |
# | o1                         | 200,000          |
# | o1-mini                    | 128,000          |
# | o1-preview                 | 128,000          |
# | o1-pro                     | 200,000          |
# | o3-mini                    | 200,000          |
# +----------------------------+------------------+

set -euo pipefail

# or copy & paste the `c()` function from https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
if [[ -f "${HOME}/.marslo/bin/bash-color.sh" ]]; then
  # credit: https://github.com/ppo/bash-colors
  source "${HOME}/.marslo/bin/bash-color.sh"
else
  c() { :; }
fi

# config
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare -r model="${MCX_MODEL:-gpt-4-1106-preview}"
declare -r temperature="${MCX_TEMPERATURE:-0.3}"
declare -r OPENAI_API_KEY="${OPENAI_API_KEY:?OPENAI_API_KEY not set}"

# flags
declare doUntracked=true
declare doFzf=false
declare -a diffOpt=()
declare USAGE="""
NAME
  ${ME} - $(c Ys)c$(c)hatgpt $(c Ys)c$(c)hange $(c Ys)m$(c)essage - Review a Git diff using ChatGPT API

USAGE
  $(c Ys)\$ ${ME}$(c) $(c Wdi)[$(c)$(c Gis)options$(c)$(c Wdi)]$(c) $(c Wdi)[$(c)$(c Bi)--$(c) $(c Mi)GIT DIFF ARGUMENTS$(c)$(c Wdi)]$(c)

OPTIONS
  $(c Gis)--help$(c), $(c Gis)-h$(c)           Show this help message
  $(c Gis)--untracked$(c)          Include untracked files in the diff
  $(c Gis)--no-untracked$(c)       Exclude untracked files in the diff
  $(c Gis)--fzf$(c)                Use fzf to select untracked files
  $(c Gis)--no-fzf$(c)             Do not use fzf to select untracked files

GIT DIFF ARGUMENTS
  Anything after $(c Bi)--$(c) is passed directly to $(c Bi)\`git diff\`$(c).

EXAMPLES
  $(c Ys)\$ ${ME}$(c)                       $(c Wdi)# use unstaged diff$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c)           $(c Wdi)# use staged diff$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)HEAD^..HEAD$(c)        $(c Wdi)# compare specific commits$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c) $(c Bi)--$(c) $(c Mi)src/$(c)   $(c Wdi)# diff staged files in src/$(c)

ENVIRONMENT VARIABLES
  MCX_MODEL             model to use (default: $(c Ci)gpt-4-1106-preview$(c))
  MCX_TEMPERATURE       temperature for model response (default: $(c Ci)0.3$(c))
  OPENAI_API_KEY$(c R)*$(c)       your OpenAI API key ($(c Ri)required$(c), read from $(c i)environment variables$(c))
"""

function showHelp() { echo -e "${USAGE}"; }
function die() { echo -e "$(c Ri)ERROR$(c)$(c i): $*.$(c) $(c Wdi)exit ...$(c)" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help | -h        ) showHelp          ; exit 0    ;;
    --untracked        ) doUntracked=true  ; shift     ;;
    --no-untracked     ) doUntracked=false ; shift     ;;
    --fzf              ) doFzf=true        ; shift     ;;
    --no-fzf           ) doFzf=false       ; shift     ;;
    --                 ) shift; diffOpt+=("$@"); break ;;
    *                  ) die "unknown option: '$(c Mi)$1$(c)'. try $(c Gi)-h$(c)/$(c Gi)--help$(c). exit ..." ;;
  esac
done

if "${doFzf}"; then
  type -P fzf >/dev/null 2>&1 || die "--fzf provided but fzf is not installed"
fi

function createDiff() {
  local modified
  modified=$(git --no-pager diff --color=never "${diffOpt[@]}")

  # return "${modified}" if no untracked files are found
  [[ "${doUntracked}" == false ]] && { echo "${modified}"; return; }

  local untracked=''
  local -a selectedFiles=()
  local -a allFiles=()

  mapfile -t allFiles < <(git ls-files --others --exclude-standard)
  if [[ "${#allFiles[@]}" -gt 0 ]]; then
    if [[ "$doFzf" == true ]]; then
      mapfile -t selectedFiles < <( printf "%s\n" "${allFiles[@]}" | fzf --multi --prompt="untracked files> " )
    else
      selectedFiles=("${allFiles[@]}")
    fi

    for file in "${selectedFiles[@]}"; do
      [[ -d "$file" ]] && continue
      fileDiff=$(git --no-pager diff --no-index --color=never /dev/null "$file" 2>/dev/null || true)
      untracked+=$'\n'"$fileDiff"
    done
  fi

  echo "${modified}${untracked}"
}

# more spinner format can be found in https://gist.github.com/marslo/96f5d6e796f59ba79de2b1a12b3b318f
function withSpinner() {
  local msg="$1"; shift
  local __resultvar="$1"; shift
  local spinner=(
    "$(c Rs)⣄$(c)"
    "$(c Ys)⣆$(c)"
    "$(c Gs)⡇$(c)"
    "$(c Bs)⠏$(c)"
    "$(c Ms)⠋$(c)"
    "$(c Ys)⠹$(c)"
    "$(c Gs)⢸$(c)"
    "$(c Bs)⣰$(c)"
    "$(c Ms)⣠$(c)"
  )
  local frame=0
  local output
  local cmd_pid
  local pgid=''
  local interrupted=0

  # define the cursor recovery function
  restoreCursor() { printf "\033[?25h" >&2; }

  # make sure that any exit restores the cursor
  trap 'restoreCursor' EXIT

  # hide cursor
  printf "\033[?25l" >&2
  printf "%s " "$msg" >&2

  set -m
  trap 'interrupted=1; [ -n "$pgid" ] && kill -TERM -- -$pgid 2>/dev/null' INT

  # use file descriptor to capture output
  local tmpout
  tmpout=$(mktemp)
  exec 3<> "${tmpout}"

  # shellcheck source=/dev/null disable=SC2031,SC2030
  output="$(
    {
      # execute command and redirect output to file descriptor 3
      "$@" >&3 2>/dev/null &
      cmd_pid=$!
      pgid=$(ps -o pgid= "$cmd_pid" | tr -d ' ')

      # update the spinner while the command is running
      while kill -0 "$cmd_pid" 2>/dev/null && (( interrupted == 0 )); do
        printf "\r\033[K%s %b" "${msg}" "${spinner[frame]}" >&2
        ((frame = (frame + 1) % ${#spinner[@]}))
        sleep 0.08
      done

      wait "$cmd_pid" 2>/dev/null
      # show the captured content
      cat "${tmpout}"
    }
  )"

  # clean the temporary file
  exec 3>&-
  rm -f "${tmpout}"

  # shellcheck source=/dev/null disable=SC2031
  if (( interrupted )); then
    printf "\r\033[K\033[31m✗\033[0m Interrupted!\033[K\n" >&2
    [ -n "${pgid}" ] && kill -TERM -- -"${pgid}" 2>/dev/null
  else
    # printf "\r\033[K\033[32m✓\033[0m Done!\033[K\n" >&2
    printf "\r" >&2
  fi

  # assign the result to an external variable
  printf -v "$__resultvar" "%s" "$output"
}

function main() {
  declare diff
  diff="$(createDiff)"
  [[ -z "${diff}" ]] && die "no diff found"

  declare prompt="Generate a Git commit message in the Conventional Commits format, with the following structure:

  <type>(<scope1,scope2,...>): short summary

  - detail 1 ( lowercase first letter )
  - detail 2 ( lowercase first letter )
  - ...

  Use multiple scopes if the diff includes changes in multiple areas.
  Use markdown-style bullet points for details and initials in lowercase.
  Ignore timestamp changes in script metadata.
  Do not include explanations or code.
  Base it on the following diff:

  ${diff}
  "

  declare payload
  payload=$(jq -n \
    --arg model "${model}" \
    --arg temp "${temperature}" \
    --arg prompt "${prompt}" \
    '{
      model: $model,
      temperature: ($temp | tonumber),
      messages: [
        { role: "system", content: "You are an assistant that writes Git commit messages." },
        { role: "user", content: $prompt }
      ]
    }')

  tmpfile=$(mktemp)
  trap 'rm -f "${tmpfile}"' EXIT

  declare response=''
  withSpinner "" response \
    curl -s https://api.openai.com/v1/chat/completions \
      -H "Authorization: Bearer ${OPENAI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "${payload}"

  echo "${response}" | jq -r '.choices[0].message.content'
}

main "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
