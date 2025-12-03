#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2155
#=============================================================================
#     FileName : ccm.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-03-21 03:34:24
#   LastChange : 2025-12-02 23:57:02
#  Description : ccm - [c]hatgpt [c]ommit [m]essage generator
#                +----------------------+--------------------+------------+
#                | ENVIRONMENT VARIABLE | DEFAULT VALUE      | NOTES      |
#                +----------------------+--------------------+------------+
#                | MCX_MODEL            | gpt-5-nano         | -          |
#                | MCX_TEMPERATURE      | 0.3                | -          |
#                | OPENAI_API_KEY       | env.OPENAI_API_KEY | mandatory* |
#                +----------------------+--------------------+------------+
#=============================================================================

# OpenAI Models:
#   - https://platform.openai.com/docs/models/gpt-5
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
# | gpt-5                      | 400,000          |
# | gpt-5-mini                 | 400,000          |
# | gpt-5-nano                 | 400,000          |
# | gpt-5.1                    | 400,000          |
# | gpt-5.1-chat-latest        | 128,000          |
# | gpt-5-codex                | 400,000          |
# | gpt-5.1-codex              | 400,000          |
# | gpt-5.1-codex-mini         | 400,000          |
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
# check Token Limit via https://platform.openai.com/settings/organization/limits
# declare -r model="${MCX_MODEL:-gpt-5.1}"        # smarter
declare -r model="${MCX_MODEL:-gpt-5-nano}"       # cheaper + faster
declare temperature="${MCX_TEMPERATURE:-0.3}"     # temperature must be 1 for gpt-5-nano
[[ "${model}" == gpt-5-nano* ]] && temperature="1"
declare -r OPENAI_API_KEY="${OPENAI_API_KEY:?OPENAI_API_KEY not set}"

# flags
declare DO_UNTRACKED=true
declare DO_FZF=false
declare -a diffOpt=()
declare VERBOSE=false
declare USAGE="""
NAME
  ${ME} - $(c Ys)c$(c)hatgpt $(c Ys)c$(c)hange $(c Ys)m$(c)essage - Review a Git diff using ChatGPT API

USAGE
  $(c Ys)\$ ${ME}$(c) $(c Wdi)[$(c)$(c Gis)options$(c)$(c Wdi)]$(c) $(c Wdi)[$(c)$(c Bi)--$(c) $(c Mi)GIT DIFF ARGUMENTS$(c)$(c Wdi)]$(c)

OPTIONS
  $(c Gis)--untracked$(c)          include untracked files in the diff
  $(c Gis)--no-untracked$(c)       exclude untracked files in the diff
  $(c Gis)--fzf$(c)                use fzf to select untracked files
  $(c Gis)--no-fzf$(c)             do not use fzf to select untracked files
  $(c Gis)--help$(c), $(c Gis)-h$(c)           show this help message
  $(c Gis)-v$(c), $(c Gis)--verbose$(c)        enable verbose output

GIT DIFF ARGUMENTS
  Anything after $(c Bi)--$(c) is passed directly to $(c Bi)\`git diff\`$(c).

EXAMPLES
  $(c Ys)\$ ${ME}$(c)                       $(c Wdi)# use unstaged diff$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c)           $(c Wdi)# use staged diff$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)HEAD^..HEAD$(c)        $(c Wdi)# compare specific commits$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c) $(c Bi)--$(c) $(c Mi)src/$(c)   $(c Wdi)# diff staged files in src/$(c)

ENVIRONMENT VARIABLES
  MCX_MODEL             model to use (default: $(c Ci)${model}$(c))
  MCX_TEMPERATURE       temperature for model response (default: $(c Ci)0.3$(c))
  OPENAI_API_KEY$(c R)*$(c)       your OpenAI API key ($(c Ri)required$(c), read from $(c i)environment variables$(c))
"""

function showHelp() { echo -e "${USAGE}"; }
function die() { echo -e "$(c Ri)ERROR$(c)$(c i): $*.$(c) $(c Wdi)exit ...$(c)" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help | -h        ) showHelp           ; exit 0    ;;
    --untracked        ) DO_UNTRACKED=true  ; shift     ;;
    --no-untracked     ) DO_UNTRACKED=false ; shift     ;;
    --fzf              ) DO_FZF=true        ; shift     ;;
    --no-fzf           ) DO_FZF=false       ; shift     ;;
    -v | --verbose     ) VERBOSE=true       ; shift     ;;
    --                 ) shift; diffOpt+=("$@"); break  ;;
    *                  ) die "unknown option: '$(c Mi)$1$(c)'. try $(c Gi)-h$(c)/$(c Gi)--help$(c). exit ..." ;;
  esac
done

if "${DO_FZF}"; then
  type -P fzf >/dev/null 2>&1 || die "--fzf provided but fzf is not installed"
fi

function cleanfile() { local file="${1:-}"; test -f "${file}" && rm -f -- "${file}"; }
function createDiff() {
  local -a excludes=( '**/.ssh/**' '**/*.key' '**/*.pem' '**/id_ed25519*' '**/.netrc' '**/credential.*' )
  local modified=$(git --no-pager diff --color=never "${diffOpt[@]}" -- . "${excludes[@]/#/:(glob,exclude)}")

  # return "${modified}" if no untracked files are found
  [[ "${DO_UNTRACKED}" == false ]] && { echo "${modified}"; return; }

  local untracked=''
  local -a selectedFiles=()
  local -a allFiles=()

  mapfile -t allFiles < <(git ls-files --others --exclude-standard -- . "${excludes[@]/#/:(glob,exclude)}")
  if [[ "${#allFiles[@]}" -gt 0 ]]; then
    if [[ "$DO_FZF" == true ]]; then
      mapfile -t selectedFiles < <( printf "%s\n" "${allFiles[@]}" | fzf --multi --prompt="untracked files> " )
    else
      selectedFiles=("${allFiles[@]}")
    fi

    for file in "${selectedFiles[@]}"; do
      [[ -d "$file" ]] && continue
      fileDiff=$(git --no-pager diff --no-index --color=never /dev/null "${file}" 2>/dev/null || true)
      untracked+=$'\n'"${fileDiff}"
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
  local cmdPid
  local pgid=''
  local interrupted=0
  local tmpout tmperr
  local innerStatus=0   # subshell exit code

  restoreCursor()  { printf "\033[?25h" >&2; }
  cleanupSpinner() { printf '\r\033[K' >&2; restoreCursor; }

  # ensure cursor restoration on any exit
  trap 'restoreCursor' EXIT

  # hide cursor and print prefix
  printf "\033[?25l" >&2
  printf "%s " "${msg}" >&2

  # kill subprocess group on job control + Ctrl-C
  set -m
  trap 'interrupted=1; [[ -n "${pgid}" ]] && kill -TERM -- -"${pgid}" 2>/dev/null' INT

  tmpout="$(mktemp "/tmp/ccm-tmpout.XXXXXX")" || return 1
  tmperr="$(mktemp "/tmp/ccm-tmperr.XXXXXX")" || { rm -f "${tmpout}"; return 1; }

  # subshell, use the exit code of the command as the exit code of the subshell
  output="$(
    {
      local cmdStatus=0

      # execute the command in subshell
      # redirect stdout -> tmpout, stderr -> tmperr
      "$@" >"${tmpout}" 2>"${tmperr}" &
      cmdPid=$!
      pgid="$(ps -o pgid= "${cmdPid}" | tr -d ' ')"

      # spinner loop
      while kill -0 "${cmdPid}" 2>/dev/null && (( interrupted == 0 )); do
        printf "\r\033[K%s %b" "${msg}" "${spinner[frame]}" >&2
        (( frame = (frame + 1) % ${#spinner[@]} ))
        sleep 0.08
      done

      if (( interrupted )); then
        # if ctrl-c happened, kill the process group, and returns 130
        wait "${cmdPid}" 2>/dev/null || true
        cmdStatus=130
      else
        # if command finished: get the real exit code; using close errexit to avoid exiting on non-zero
        set +e
        wait "${cmdPid}"
        cmdStatus=$?
        set -e
      fi

      # print the command output from temp file, it will be captured by $(...)
      cat "${tmpout}"
      # exit code of subshell, so the $? outside is $cmdStatus, not 0
      exit "${cmdStatus}"
    }
  )"

  # subshell exit code (== $cmdStatus)
  innerStatus=$?

  cleanupSpinner                      # cursor revert to beginning of line + clear line + show cursor
  trap - INT                          # dismiss the INT trap, to avoid impacting the next commands

  # if Ctrl-C happened, just print interrupted message, no stderr shows
  if (( innerStatus == 130 )); then
    printf "\033[31m✗\033[0m Interrupted!\n" >&2
  else
    # not stopped by ctrl+c AND exit code != 0, print stderr
    if (( innerStatus != 0 )) && [[ -s "${tmperr}" ]]; then
      # print the stderr content
      printf "$(c Wdi)>> exit code : $(c 0Mi)%d$(c 0Wdi).\n>> stderr    : $(c 0Mi)" "${innerStatus}" >&2
      cat "${tmperr}" >&2
      printf "%s" "$(c)" >&2
    fi
    # nothing to be processed for success case
    # printf "\r\033[K\033[32m✓\033[0m Done!\033[K\n" >&2
    printf "\r" >&2
  fi

  # cleanup temp files
  cleanfile "${tmpout:-}"
  cleanfile "${tmperr:-}"

  # put the stdout into the variable provided by caller
  printf -v "${__resultvar}" '%s' "${output}"
  # return the inner command's exit code
  return "${innerStatus}"
}

function main() {
  declare diff
  diff="$(createDiff)"
  test -z "${diff}" && die "no diff found"
  # count diff size
  local bytes=${#diff}
  local kib=$(( bytes / 1024 ))
  local mib=$(( kib / 1024 ))
  "${VERBOSE}" && echo -e "$(c Wdi)------------ DEBUG INFO -------------$(c)"
  "${VERBOSE}" && printf "$(c Wdi)  diff size: %d bytes (~%d KiB, ~%d MiB)$(c)\n" "${bytes}" "${kib}" "${mib}" >&2

  local prompt="Generate a Git commit message in the Conventional Commits format, with the following structure:

  <type>(<scope1,scope2,...>): short summary

  - detail 1 ( lowercase first letter )
  - detail 2 ( lowercase first letter )
  - ...

  Use multiple scopes if the diff includes changes in multiple areas.
  Use markdown-style bullet points for details and initials in lowercase.
  Each bullet should start directly with a lowercase verb phrase (e.g., update docs, fix bug ...).
  Do NOT prefix bullet points with a single-letter label or initial.
  Do not include timestamp changes in script/code metadata.
  Do not include explanations or code.
  Base it on the following diff:

  ${diff}
  "

  local payload
  local plfile="$(mktemp "/tmp/ccm-payload.XXXXXX.json")"
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

  printf '%s\n' "${payload}" > "${plfile}"
  local payloadBytes=$(wc -c < "${plfile}")
  "${VERBOSE}" && printf "$(c Wdi)  payload dumped to %s (size: %d bytes, ~%d KiB)$(c)\n" "${plfile}" "${payloadBytes}" "$(( payloadBytes / 1024 ))" >&2
  "${VERBOSE}" && echo -e "$(c Wdi)-------------------------------------$(c)"

  declare response=''
  if withSpinner '' response \
    curl -sS --http1.1 https://api.openai.com/v1/chat/completions \
      -H "Authorization: Bearer ${OPENAI_API_KEY}" \
      -H "Content-Type: application/json" \
      --data-binary "@${plfile}"
  then
    curlExit=0
  else
    curlExit=$?
  fi

  # if curl error
  if (( curlExit != 0 )); then die "curl failed with exit code: $(c 0Mi)${curlExit}$(c)"; fi

  # if error
  if jq -e '.error' >/dev/null <<<"${response}"; then
    echo "${response}" | jq . >&2
    die "OpenAI API returned an error (see above)"
  fi

  echo "${response}" | jq -r '.choices[0].message.content'
  trap 'cleanfile "${plfile:-}"' EXIT
}

main "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
