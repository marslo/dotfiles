#!/usr/bin/env bash
# =============================================================================
#      FileName : ls-stgs.sh
#        Author : marslo
#       Created : 2026-06-02 17:03:32
#    LastChange : 2026-06-23 23:09:41
# =============================================================================

set -euo pipefail

# shellcheck disable=SC2155
declare -r HERE="$( dirname "${BASH_SOURCE[0]:-$0}" )"
# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
source "${HERE}/bash-colors.sh" 2>/dev/null || { c() { :; }; }

declare JOB_NAME='release'
declare BUILD_NUMBER=''
declare SHOW_MODE='failure'
declare VERBOSE=0
# results treated as "interesting" in --failure mode (add UNSTABLE|ABORTED if needed)
declare BAD_RESULTS='FAILURE|NOT_BUILT'
# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
# shellcheck disable=SC2155
declare -r USAGE="NAME
  ${ME} - A Jenkins pipeline stage tree viewer in bash

SYNOPSIS
  $(c 0Ys)\$ ${ME} $(c 0Gi)[OPTIONS]$(c)

OPTIONS
  $(c 0G)-d$(c), $(c 0G)--domain $(c 0Mi)<JENKINS_HOST>$(c) jenkins host $(c 0i)(default: $(c 0Ci)${JENKINS_HOST:-}$(c 0i))$(c)
  $(c 0G)-j$(c), $(c 0G)--job $(c 0Mi)<JOB_NAME>$(c)        jenkins job name $(c 0i)(default: $(c 0Ci)${JOB_NAME}$(c 0i))$(c)
  $(c 0G)-b$(c), $(c 0G)--build $(c 0Mi)<BUILD_NUMBER>$(c)  jenkins build number
  $(c 0G)-u$(c), $(c 0G)--url $(c 0Mi)<BUILD_URL>$(c)       full jenkins build url (classic/blueocean); parses host, job and build
  $(c 0G)-f$(c), $(c 0G)--failure$(c)               show only stages on paths containing FAILURE $(c 0i)($(c 0Ci)default$(c 0i))$(c)
  $(c 0G)-a$(c), $(c 0G)--all$(c)                   show all stages
  $(c G)-v$(c)                          multiple $(c 0Gi)-v$(c) options increase verbosity $(c 0i)(max: $(c 0Yi)1$(c))$(c)
  $(c 0G)-h$(c), $(c 0G)--help$(c)                  show this help message and exit
"

# parse a full jenkins build url and populate JENKINS_HOST / JOB_NAME / BUILD_NUMBER.
# supported formats:
#   with view : https://<host>/view/<v>/job/<A>/job/<B>/<build>/
#   classic   : https://<host>/job/<A>/job/<B>/<build>/
#   blueocean : https://<host>/blue/organizations/jenkins/<A%2FB>/detail/<name>/<build>/pipeline
# exits if no build number can be found.
function parseUrl() {
  local url="${1:?the build url is required}"
  local proto='' rest host path job='' build='' i

  # shellcheck disable=SC2015
  [[ "${url}" =~ ^(https?://) ]] && { proto="${BASH_REMATCH[1]}"; rest="${url#"${proto}"}"; } || rest="${url}"
  host="${rest%%/*}"                 # <host>[:port]
  path="/${rest#*/}"                 # path with leading slash
  [[ "${rest}" == "${host}" ]] && path=''

  if [[ "${path}" == /blue/* ]]; then
    # /blue/organizations/<org>/<PIPELINE>/detail/<name>/<build>/pipeline
    local pipeline tail
    pipeline="${path#/blue/organizations/*/}"   # <PIPELINE>/detail/...
    pipeline="${pipeline%%/detail/*}"           # url-encoded job, e.g. UnifiedSDK%2Frelease
    job="$( printf '%b' "${pipeline//%/\\x}" )" # url-decode (%2F -> /)
    tail="${path#*/detail/}"                    # <name>/<build>/pipeline...
    local -a _p; IFS='/' read -ra _p <<< "${tail}"
    build="${_p[1]:-}"
  else
    # classic (with or without /view/...): collect each segment following 'job'
    local -a seg job_parts=()
    IFS='/' read -ra seg <<< "${path}"
    for (( i=0; i<${#seg[@]}; i++ )); do
      if [[ "${seg[i]}" == 'job' ]]; then
        job_parts+=( "${seg[i+1]:-}" )
        i=$(( i + 1 ))
      fi
    done
    job="$( IFS='/'; echo "${job_parts[*]}" )"
    # build = last purely-numeric path segment
    for (( i=${#seg[@]}-1; i>=0; i-- )); do
      [[ "${seg[i]}" =~ ^[0-9]+$ ]] && { build="${seg[i]}"; break; }
    done
  fi

  [[ "${build}" =~ ^[0-9]+$ ]] || { echo "ERROR: no build number found in url: ${url}" >&2; exit 1; }
  [[ -n "${job}" ]] || { echo "ERROR: cannot parse job name from url: ${url}" >&2; exit 1; }

  JENKINS_HOST="${proto}${host}"
  JOB_NAME="${job}"
  BUILD_NUMBER="${build}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d | --domain  ) JENKINS_HOST="$2"        ; shift 2 ;;
    -j | --job     ) JOB_NAME="$2"            ; shift 2 ;;
    -b | --build   ) BUILD_NUMBER="$2"        ; shift 2 ;;
    -u | --url     ) parseUrl "$2"            ; shift 2 ;;
    -f | --failure ) SHOW_MODE='failure'      ; shift   ;;
    -a | --all     ) SHOW_MODE='all'          ; shift   ;;
    -v | -vv       ) VERBOSE=$(( ${#1} - 1 )) ; shift   ;;
    -h | --help    ) echo -e "${USAGE}" >&2   ; exit 0  ;;
    *              ) echo "ERROR: unknown option '$1'" >&2; exit 1;;
  esac
done

test -n "${JENKINS_HOST:-}" || JENKINS_HOST="${JENKINS_HOST:-}"
test -z "${JENKINS_HOST:-}" && { echo "ERROR: Jenkins host is not specified. Use -d or set JENKINS_HOST environment variable." >&2; exit 1; }
# shellcheck disable=SC2015
[[ "${JENKINS_HOST}" =~ ^https?:// ]] && declare JENKINS_URL="${JENKINS_HOST%/}" || declare JENKINS_URL="https://${JENKINS_HOST}"

# derive pass entry from hostname: <2nd-label>/jenkins/apikey/<1st-label>
# e.g. jenkins.domain.com -> domain/jenkins/apikey/jenkins
declare _host="${JENKINS_HOST#http*://}"; _host="${_host%%/*}"; _host="${_host%%:*}"
declare _first="${_host%%.*}"
declare _org="${_host#*.}"; _org="${_org%%.*}"
# shellcheck disable=SC2155
declare API_KEY="$( pass show "${_org}/jenkins/apikey/${_first}" 2>/dev/null | head -1 )"
test -n "${API_KEY}" || { echo "ERROR: failed to get API key from pass '${_org}/jenkins/apikey/${_first}'." >&2; exit 1; }

# shellcheck disable=SC2155
declare UI_URL="${JENKINS_URL}/blue/organizations/jenkins/$(echo -n "${JOB_NAME}" | jq -sRr @uri)/detail/$(basename "${JOB_NAME}")/${BUILD_NUMBER}/pipeline"
declare API_URL="${JENKINS_URL}/blue/rest/organizations/jenkins/pipelines/${JOB_NAME//\//\/pipelines\/}/runs/${BUILD_NUMBER}"
declare -a CURL_CMD=( command curl -s -H "X-API-Key: ${API_KEY}" )

# shellcheck disable=SC2155
declare NODES_JSON="$( "${CURL_CMD[@]}" "${API_URL}/nodes/?limit=10000" || { echo "Error fetching nodes from API" >&2; exit 1; } )"

declare -A NODE_NAME NODE_STATE NODE_RESULT NODE_TYPE NODE_CHILDREN NODE_LEVEL
declare -a ROOT_NODES=()
while IFS=$'\t' read -r id name state result type parent; do
  NODE_NAME["${id}"]="${name}"
  NODE_STATE["${id}"]="${state}"
  NODE_RESULT["${id}"]="${result}"
  NODE_TYPE["${id}"]="${type}"

  if [[ "${parent}" == "null" || -z "${parent}" ]]; then
    ROOT_NODES+=("${id}")
    NODE_LEVEL["${id}"]="__root__"
  elif [[ "${type}" == "STAGE" && "${NODE_TYPE[${parent}]:-}" == "STAGE" ]]; then
    _group="${NODE_LEVEL[${parent}]:-${parent}}"
    if [[ "${_group}" == "__root__" ]]; then
      ROOT_NODES+=("${id}")
    else
      NODE_CHILDREN["${_group}"]+="${id} "
    fi
    NODE_LEVEL["${id}"]="${_group}"
  else
    NODE_CHILDREN["${parent}"]+="${id} "
    NODE_LEVEL["${id}"]="${parent}"
  fi
done< <( echo "${NODES_JSON}" | jq -r '.[] | [.id, .displayName, .state, .result, .type, .firstParent] | @tsv' )

function color() {
  local res="${1:?the result value is required}"
  # nameref
  local -n __start=$2
  local -n __end=$3

  __start=''
  __end=''

  case "${res}" in
    FAILURE   ) __start="$(c 0Rs)"; __end="$(c)" ;;
    UNSTABLE  ) __start="$(c 0Ys)"; __end="$(c)" ;;
    NOT_BUILT ) __start="$(c 0Wi)"; __end="$(c)" ;;
    ABORTED   ) __start="$(c 0Wi)"; __end="$(c)" ;;
    SUCCESS   ) __start="$(c 0Gs)"; __end="$(c)" ;;
    *         ) ;;
  esac
}

declare -A HAS_FAILURE_CACHE
function hasFailure() {
  local _node="$1"
  if [[ -n "${HAS_FAILURE_CACHE[${_node}]+x}" ]]; then
    return "${HAS_FAILURE_CACHE[${_node}]}"
  fi
  if [[ "${NODE_RESULT[${_node}]^^}" =~ ^(${BAD_RESULTS})$ ]]; then
    HAS_FAILURE_CACHE["${_node}"]=0; return 0
  fi
  if [[ -n "${NODE_CHILDREN[${_node}]:-}" ]]; then
    local -a _kids; read -ra _kids <<< "${NODE_CHILDREN[${_node}]}"
    for _kid in "${_kids[@]}"; do
      if hasFailure "${_kid}"; then
        HAS_FAILURE_CACHE["${_node}"]=0; return 0
      fi
    done
  fi
  HAS_FAILURE_CACHE["${_node}"]=1; return 1
}

function printTree() {
  local _node="$1"
  local _prefix="$2"
  local _lastchild="$3"
  local _root="$4"

  local _curprefix=''
  local _childprefix=''

  if [[ "${_root}" == 'true' ]]; then
    _curprefix='▶ '
    _childprefix='  '
  else
    if [[ "${_lastchild}" == 'true' ]]; then
      # ╰──
      _curprefix="${_prefix}╰── "
      _childprefix="${_prefix}    "
    else
      _curprefix="${_prefix}├── "
      _childprefix="${_prefix}│   "
    fi
  fi

  local display_format="%s"
  local res="${NODE_RESULT[${_node}]^^}"
  printf -v _line "${display_format} | TYPE: %s | STATUS: %s, RESULT:" \
           "[ID: ${_node}] ${NODE_NAME[${_node}]}" \
           "${NODE_TYPE[${_node}]}" \
           "${NODE_STATE[${_node}]}"

  local _start=''
  local _end=''
  color "${res}" _start _end

  if [[ "${res}" != 'SUCCESS' ]]; then
    printf "%s%b%s %s%b\n" "${_curprefix}" "${_start}" "${_line}" "${res}" "${_end}"
  else
    printf "%s%s %b%s%b\n" "${_curprefix}" "${_line}" "${_start}" "${res}" "${_end}"
  fi

  if [[ -n "${NODE_CHILDREN[${_node}]:-}" ]]; then
    local -a children=()
    local cid
    read -ra children <<< "${NODE_CHILDREN[${_node}]}"

    local -a visible=()
    for cid in "${children[@]}"; do
      if [[ "${SHOW_MODE}" == 'all' ]] || hasFailure "${cid}"; then
        visible+=("${cid}")
      fi
    done

    local vcount=${#visible[@]}
    local i
    for (( i=0; i<vcount; i++ )); do
      local child_id=${visible[i]}
      local _lastchild="false"
      [[ $((i + 1)) -eq ${vcount} ]] && _lastchild="true"
      printTree "${child_id}" "${_childprefix}" "${_lastchild}" "false"
    done
  fi
}

[[ "${VERBOSE}" -ge 1 ]] && { echo -e "$(c 0Gs)>> Blueocean URL: $(c)${UI_URL}"; } || :
for rid in "${ROOT_NODES[@]}"; do
  if [[ "${SHOW_MODE}" == 'all' ]] || hasFailure "${rid}"; then
    printTree "${rid}" '' 'false' 'true'
  fi
done

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
