#!/usr/bin/env bash
# shellcheck source=/dev/null
#=============================================================================
#     FileName : ccr.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-03-25 08:29:23
#   LastChange : 2026-02-12 23:37:14
#=============================================================================

set -euo pipefail

# shellcheck disable=SC2155
declare -r HERE="$( dirname "${BASH_SOURCE[0]:-$0}" )"
# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${HERE}/bash-colors.sh" && source "${HERE}/bash-colors.sh" || { c() { :; }; }

# +----------------------+--------------------+---------------------+
# | ENVIRONMENT VARIABLE | DEFAULT VALUE      | NOTE                |
# +----------------------+--------------------+---------------------+
# | MCX_MODEL            | gpt-4-turbo        | gpt-4,gpt-3.5-turbo |
# | MCX_TEMPERATURE      | 0.3                | -                   |
# | OPENAI_API_KEY       | env.OPENAI_API_KEY | *mandatory          |
# +----------------------+--------------------+---------------------+

# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare -r MODEL="${MCX_MODEL:-gpt-4-turbo}"
declare -r TEMPERATURE="${MCX_TEMPERATURE:-0.3}"
declare -r OPENAI_API_KEY="${OPENAI_API_KEY:?OPENAI_API_KEY not set}"

# flags
declare doUntracked=true
declare doFzf=false
declare untrackedMode=false
declare -a diffOpt=()
# shellcheck disable=SC2155
declare USAGE="""
NAME
  ${ME} - $(c Ys)c$(c)hatgpt $(c Ys)c$(c)ode $(c Ys)r$(c)eview - Review a Git diff using ChatGPT API

USAGE
  $(c Ys)\$ ${ME}$(c) $(c Wdi)[$(c)$(c Gis)options$(c)$(c Wdi)]$(c) $(c Wdi)[$(c)$(c Bi)--$(c) $(c Mi)GIT DIFF ARGUMENTS$(c)$(c Wdi)]$(c)

OPTIONS
  $(c Gi)--help$(c), $(c Gi)-h$(c)           Show this help message
  $(c Gi)--untracked$(c)          Include untracked files in the diff
  $(c Gi)--no-untracked$(c)       Exclude untracked files in the diff
  $(c Gi)--fzf$(c)                Use fzf, requires $(c Csi)fzf$(c) to be installed
  $(c Gi)--no-fzf$(c)             Do not use fzf

GIT DIFF ARGUMENTS
  Anything after $(c Bi)--$(c) is passed directly to $(c Bi)\`git diff\`$(c).

EXAMPLES
  $(c Ys)\$ ${ME}$(c) $(c Gi)--fzf$(c)                 $(c Wdi)# use fzf for unstaged diff$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c)           $(c Wdi)# use staged diff$(c)
  $(c Ys)\$ ${ME}$(c) $(c Gi)--fzf$(c) $(c Bi)--$(c) $(c Mi)HEAD^..HEAD$(c)  $(c Wdi)# compare specific commits with fzf$(c)
  $(c Ys)\$ ${ME}$(c) $(c Bi)--$(c) $(c Mi)--cached$(c) $(c Bi)--$(c) $(c Mi)src/$(c)   $(c Wdi)# diff staged files in src/$(c)

ENVIRONMENT VARIABLES
  MCX_MODEL         model to use (default: $(c Ci)gpt-4-1106-preview$(c))
  MCX_TEMPERATURE   temperature for model response (default: $(c Ci)0.3$(c))
  OPENAI_API_KEY$(c R)*$(c)   your OpenAI API key ($(c Ri)required$(c), read from $(c i)environment variables$(c))
"""

function showHelp() { echo -e "${USAGE}"; }
function die() { echo -e "$(c Ri)ERROR$(c)$(c i): $*.$(c) $(c Wdi)exit ...$(c)" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help | -h        ) showHelp          ; exit 0    ;;
    --fzf              ) doFzf=true        ; shift     ;;
    --no-fzf           ) doFzf=false       ; shift     ;;
    --untracked        ) doUntracked=true  ; untrackedMode=true ; shift ;;
    --no-untracked     ) doUntracked=false ; untrackedMode=true ; shift ;;
    --                 ) shift; diffOpt+=("$@"); break ;;
    *                  ) die "unknown option: '$(c Mi)$1$(c)'. try $(c Gi)-h$(c)/$(c Gi)--help$(c). exit ..." ;;
  esac
done

if "${doFzf}"; then
  type -P fzf >/dev/null 2>&1 || die "$(c Ci)--fzf$(c) provided but fzf is not installed"
fi

[[ ${#diffOpt[@]} -gt 0 && "${untrackedMode}" == false ]] && doUntracked=false
[[ ${#diffOpt[@]} -gt 0 ]] && diffOptIsPresent=true || diffOptIsPresent=false

function selectFilesWithFzf() {
  local localDoUntracked="${1}"
  local localDiffOptIsPresent="${2}"
  local modifiedFiles="${3}"
  local untrackedFiles="${4}"
  local -a finalModifiedFiles=()
  local -a finalUntrackedFiles=()
  local -a fzfInputList=()
  local -a selectedOutput=()
  local fzfExitStatus=0
  local fzfPrompt=""
  local showCombinedFzf=false

  mapfile -t finalModifiedFiles  < "${modifiedFiles}"
  mapfile -t finalUntrackedFiles < "${untrackedFiles}"

  if "${localDoUntracked}" && "${localDiffOptIsPresent}" && \
    [[ "${#finalModifiedFiles[@]}" -gt 0 || "${#finalUntrackedFiles[@]}" -gt 0 ]]; then
    showCombinedFzf=true
    fzfPrompt="Select files (M: Mod, U: Untrk)> "
  elif "${localDoUntracked}" && ! "${localDiffOptIsPresent}" && [[ "${#finalUntrackedFiles[@]}" -gt 0 ]]; then
    fzfPrompt="Untracked files> "
  elif [[ "${#finalModifiedFiles[@]}" -gt 0 ]]; then
    fzfPrompt="Modified files> "
  else
    return 1
  fi

  if "${showCombinedFzf}"; then
    local taggedFile=""
    for file in "${finalModifiedFiles[@]}"; do
      printf -v taggedFile "M: %s" "${file}"
      fzfInputList+=("${taggedFile}")
    done
    for file in "${finalUntrackedFiles[@]}"; do
      printf -v taggedFile "U: %s" "${file}"
      fzfInputList+=("${taggedFile}")
    done
  elif "${localDoUntracked}" && ! "${localDiffOptIsPresent}"; then
    local taggedFile=""
    for file in "${finalUntrackedFiles[@]}"; do
      printf -v taggedFile "U: %s" "${file}"
      fzfInputList+=("${taggedFile}")
    done
  else
    local taggedFile=""
    for file in "${finalModifiedFiles[@]}"; do
      printf -v taggedFile "M: %s" "${file}"
      fzfInputList+=("${taggedFile}")
    done
  fi

  [[ "${#fzfInputList[@]}" -eq 0 ]] && return 1

  mapfile -t selectedOutput < <( printf "%s\n" "${fzfInputList[@]}" | fzf --multi --prompt="${fzfPrompt}" ) || fzfExitStatus=$?

  if [[ "${fzfExitStatus}" -ne 0 ]] || [[ "${#selectedOutput[@]}" -eq 0 ]]; then
    return 1
  else
    printf "%s\n" "${selectedOutput[@]}"
    return 0
  fi
}

function createDiff() {
  local modified=""
  local untracked=""
  local -a filesToDiffModified=()
  local -a filesToDiffUntracked=()

  local -a finalModifiedFiles=()
  mapfile -t finalModifiedFiles < <(git --no-pager diff --name-only --color=never "${diffOpt[@]}")

  local -a finalUntrackedFiles=()
  if "${doUntracked}"; then
    mapfile -t finalUntrackedFiles < <(git ls-files --others --exclude-standard)
  fi

  if "${doFzf}"; then
    local -a selectedOutput=()
    local fzfExitStatus=0

    # call the fzf handler function, passing inputs via process substitution
    mapfile -t selectedOutput < <( \
        selectFilesWithFzf \
            "${doUntracked}" \
            "${diffOptIsPresent}" \
            <(printf "%s\n" "${finalModifiedFiles[@]}") \
            <(printf "%s\n" "${finalUntrackedFiles[@]}") \
    ) || fzfExitStatus=$?

    # check if fzf was cancelled or no files were selected
    [[ "${fzfExitStatus}" -ne 0 ]] && { echo ''; return 0; }

    local taggedFile=""
    for taggedFile in "${selectedOutput[@]}"; do
      if [[ "${taggedFile}" == "M: "* ]]; then
        filesToDiffModified+=("${taggedFile#M: }")
      elif [[ "${taggedFile}" == "U: "* ]]; then
        # Only add untracked if doUntracked is still true (safety check)
        "${doUntracked}" && filesToDiffUntracked+=("${taggedFile#U: }")
      fi
    done

  else
    # no fzf
    filesToDiffModified=("${finalModifiedFiles[@]}")
    if "${doUntracked}"; then
      filesToDiffUntracked=("${finalUntrackedFiles[@]}")
    fi
  fi

  if [[ "${#filesToDiffModified[@]}" -gt 0 ]]; then
    modified=$(git --no-pager diff --color=never --unified=0 "${diffOpt[@]}" -- "${filesToDiffModified[@]}")
  fi

  if [[ "${#filesToDiffUntracked[@]}" -gt 0 ]]; then
    local fileDiff
    for file in "${filesToDiffUntracked[@]}"; do
      [[ -d "${file}" ]] && continue
      fileDiff=$(git --no-pager diff --no-index --color=never --unified=0 /dev/null "${file}" 2>/dev/null || true)
      if [[ -n "${fileDiff}" ]]; then
        if [[ -n "${modified}" || -n "${untracked}" ]]; then
          untracked+=$'\n'
        fi
        untracked+="${fileDiff}"
      fi
    done
  fi

   if [[ -n "${modified}" && -n "${untracked}" ]]; then
    echo "${modified}"$'\n'"${untracked}"
  elif [[ -n "${modified}" ]]; then
    echo "${modified}"
  elif [[ -n "${untracked}" ]]; then
    echo "${untracked}"
  else
    echo ''
  fi
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
  # shellcheck disable=SC2329
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

  declare prompt="You are a Principal Software Architect reviewing a Git diff.

  You may not have the full code context, but please still provide a professional code review.

  Focus on:
  - What the changes are doing
  - Code quality, style, naming, structure
  - Potential bugs or anti-patterns
  - Suggestions for improvement

  Use markdown. Be helpful, concise, and insightful.

  --- START DIFF ---
  ${diff}
  --- END DIFF ---"

  declare response=''
  withSpinner "" response \
  curl -s https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
      --arg model "$MODEL" \
      --arg temp "$TEMPERATURE" \
      --arg prompt "$prompt" \
      ' {
        model: $model,
        temperature: ($temp | tonumber),
        messages: [
          { role: "system", content: "You are a senior engineer performing code review." },
          { role: "user", content: $prompt }
        ]
      }')"

  echo "${response}" | jq -r '.choices[0].message.content'
}

main "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
