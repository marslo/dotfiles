#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2155
#=============================================================================
#     FileName : ccm.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-03-21 03:34:24
#   LastChange : 2025-04-07 15:23:48
#  Description : ccm - [c]hatgpt [c]ommit [m]essage generator
#                +----------------------+--------------------+------------+
#                | ENVIRONMENT VARIABLE | DEFAULT VALUE      | NOTES      |
#                +----------------------+--------------------+------------+
#                | COMMITX_MODEL        | gpt-4-1106-preview | -          |
#                | COMMITX_TEMPERATURE  | 0.3                | -          |
#                | OPENAI_API_KEY       | env.OPENAI_API_KEY | mandatory* |
#                +----------------------+--------------------+------------+
#=============================================================================

set -euo pipefail
source "${HOME}"/.marslo/bin/bash-color.sh

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

function showHelp() { echo -e "${USAGE}"; }
function die() { echo -e "$(c R)ERROR$(c) : $*. exit ..." >&2; exit 1; }
function showError() { echo -e "$(c R)ERROR$(c) : $*. exit ..." >&2; }

declare model="${COMMITX_MODEL:-gpt-4-1106-preview}"
declare temperature="${COMMITX_TEMPERATURE:-0.3}"
declare OPENAI_API_KEY="${OPENAI_API_KEY:? OPENAI_API_KEY not set}"
declare ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare USAGE="""
NAME
  ${ME} - Generate a Git commit message using OpenAI API

USAGE
  $(c Ys)\$ ${ME}$(c) $(c Wdi)[$(c)$(c Gis)options$(c)$(c Wdi)]$(c) $(c Wdi)[$(c)$(c Bi)--$(c) $(c Mi)GIT DIFF ARGUMENTS$(c)$(c Wdi)]$(c)

OPTIONS
  $(c Gis)--help$(c), $(c Gis)-h$(c)           Show this help message

GIT DIFF ARGUMENTS
  Anything after $(c Bi)--$(c) is passed directly to $(c Bi)\`git diff\`$(c).

EXAMPLES
  $(c Ys)\$ ${ME}$(c)                       # use unstaged diff
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c)           # use staged diff
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)HEAD^..HEAD$(c)        # compare specific commits
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c) $(c Bi)--$(c) $(c Mi)src/$(c)   # diff staged files in src/

ENVIRONMENT VARIABLES
  COMMITX_MODEL         model to use (default: $(c Ci)gpt-4-1106-preview$(c))
  COMMITX_TEMPERATURE   temperature for model response (default: $(c Ci)0.3$(c))
  OPENAI_API_KEY$(c R)*$(c)       your OpenAI API key ($(c Ri)required$(c), read from $(c i)environment variables$(c))
"""
declare -a diffOpt=()
declare doUntracked=true
declare doFzf=false
declare diff

function getDiff() {
  local modified
  modified=$(git --no-pager diff --color=never "${diffOpt[@]}")

  [[ "${doUntracked}" == false ]] && { echo "${modified}"; return; }

  local untracked=''
  local -a selectedFiles=()
  local -a allFiles=()

  mapfile -t allFiles < <(git ls-files --others --exclude-standard)

  if [[ "${#allFiles[@]}" -gt 0 ]]; then
    if [[ "${doFzf}" == true ]]; then
      type -P fzf >/dev/null 2>&1 || { showError "--fzf provided but fzf is not installed"; exit 1; }
      mapfile -t selectedFiles < <( printf "%s\n" "${allFiles[@]}" |
                                    fzf --multi --prompt="untracked files> "
                                  )
    else
      selectedFiles=("${allFiles[@]}")
    fi

    for file in "${selectedFiles[@]}"; do
      test -d "${file}" && continue
      file_diff=$(git --no-pager diff --no-index --color=never /dev/null "${file}" 2>/dev/null || true)
      untracked+=$'\n'"$file_diff"
    done
  fi

  echo "${modified}${untracked}"
}

diff="$(getDiff)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help | -h    ) showHelp          ; exit 0    ;;
    --untracked    ) doUntracked=true  ; shift     ;;
    --no-untracked ) doUntracked=false ; shift     ;;
    --fzf          ) doFzf=true        ; shift     ;;
    # pass everything after -- to git
    --             ) shift; diffOpt+=("$@"); break ;;
    *              ) echo -e "$(c Ri)ERROR$(c): unknown option: '$(c Mi)$1$(c)'. try $(c Gi)-h$(c)/$(c Gi)--help$(c). exit ..." >&2; exit 1 ;;
  esac
done

diff=$(git --no-pager diff --color=never "${diffOpt[@]}")
prompt="Generate a Git commit message in the Conventional Commits format, with the following structure:

<type>(<scope1,scope2,...>): short summary

- detail 1
- detail 2
- ...

Use multiple scopes if the diff includes changes in multiple areas.
Use markdown-style bullet points for details.
Do not include explanations or code.
Base it on the following diff:

${diff}
"

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

curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "${payload}" |
jq -r '.choices[0].message.content'

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
