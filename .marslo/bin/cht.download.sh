#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2155
#=============================================================================
#     FileName : cht.download.sh
#       Author : marslo
#      Created : 2026-03-04 00:46:18
#   LastChange : 2026-03-04 11:12:10
#=============================================================================

set -euo pipefail

trap 'echo -e "\n$(c 0Rs)[ERROR] $(c 0Wdi)Interrupted by user (Ctrl+C). Exiting...$(c)" >&2; exit 130' INT

declare -r CS_CACHE_DIR="${CS_CACHE_DIR:-$HOME/.config/cht.sh}"
declare FULL_DOWNLOAD=false
declare SUB_LIST=false
declare VERBOSE=1

# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${HOME}/.marslo/bin/bash-colors.sh" && source "${HOME}/.marslo/bin/bash-colors.sh" || { c() { :; }; }
function showUsage() { echo -e "${USAGE}"; exit 0; }

declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare -r USAGE="USAGE:
  $(c Y)\$ ${ME} $(c 0G)[OPTIONS]$(c)

OPTIONS:
  $(c G)--update$(c)             only download missing or updated cheat sheets $(c 0Ci)(default)$(c)
  $(c G)--full-download$(c)      force full download of all cheat sheets
  $(c G)--sub-list$(c)           also check sub-lists under directories $(c 0Mi)(e.g. https://cht.sh/awk/:list)$(c) for new cheat sheets
  $(c G)--dryrun$(c)             show what would be downloaded without actually downloading
  $(c G)-s$(c), $(c G)--silent$(c)         suppress all output except errors
  $(c G)-v$(c), $(c G)-vv$(c)              show debug information. multiple -v options increase verbosity $(c 0Ci)(max: $(c 0Mi)2$(c 0Ci), default: $(c 0Mi)1$(c 0Ci))$(c)
  $(c G)-h$(c), $(c G)--help$(c)           show this help message and exit
"

function getRemoteList() {
  local raw files dirs allFiles subList expanded _c

  "${SUB_LIST}" && _c="$(c 0Wdi)and $(c 0Ci)https://cht.sh/<DIR>:list " || _c=""
  echo -e "$(c Wdi)>> get remote list from $(c 0Ci)https://cht.sh/:list ${_c}$(c 0Wdi)...$(c)" >&2

  raw=$(curl -fsSL -g "https://cht.sh/:list" | awk 'NF && !/ / && !/^rfc\//')
  files=$(echo "${raw}" | grep -v '/$' || true)
  dirs=$(echo "${raw}" | grep '/$' || true)
  allFiles="${files}"

  if ! "${SUB_LIST}"; then
    echo -e "$(c Wdi)>> skipping sub-list check, only top-level cheat sheets will be downloaded$(c)" >&2
    echo -e "${allFiles}" | sort -u
    return
  fi

  if [[ -z "${dirs}" ]]; then
    echo -e "$(c Wdi)>> no sub-list found, only top-level cheat sheets will be downloaded$(c)" >&2
    echo -e "${allFiles}" | sort -u
    return
  fi

  trap 'exit 130' SIGINT SIGTERM; while read -r dir; do
    [[ -z "${dir}" ]] && continue

    [[ "${VERBOSE}" -ge 2 ]] && echo -e "$(c 0Wdi)== checking sub list: $(c 0Mi)'cht.sh/${dir}:list'$(c 0Wdi) ...$(c)" >&2
    subList=$(curl -fsSL -g "https://cht.sh/${dir}:list" 2>/dev/null | awk 'NF && !/ /')

    if [[ -n "${subList}" ]]; then
      expanded=$(echo "${subList}" | awk -v prefix="${dir}" '{print prefix $0}')
      allFiles="${allFiles}\n${expanded}"
    fi

    sleep 0.01
  done <<< "${dirs}"

  # 1. NF: filter out empty lines
  # 2. !/\/$/: filter out directory entries (ending with '/')
  # 4. !/^rfc\//: filter out entries starting with 'rfc/' (not actual cheat sheets)
  echo -e "${allFiles}" | awk 'NF && !/\/$/ && !/^rfc\//' | sort -u
}

function getLocalList() {
  test -d "${CS_CACHE_DIR}" || mkdir -p "${CS_CACHE_DIR}"
  [[ "${VERBOSE}" -ge 1 ]] && echo -e "$(c Wdi)>> scan local cache directory: $(c 0Mi)'${CS_CACHE_DIR}'$(c 0Wdi) ...$(c)" >&2
  if type -P rg >/dev/null; then
    ( cd "${CS_CACHE_DIR}" && rg --files -u | sed 's|^_||' | sort ) || true
  else
    ( cd "${CS_CACHE_DIR}" && find . -type f ! -name ".*" | sed 's|^\./||' | sed 's|^_\(.*\)|\1|' | sort ) || true
  fi
}

function getList() {
  if "${FULL_DOWNLOAD}"; then
    getRemoteList
  else
    [[ "${VERBOSE}" -ge 1 ]] && [[ "${VERBOSE}" -ge 1 ]] && echo -e "$(c Wdi)>> compare local and remote lists to find missing items ...$(c)" >&2
    comm -13 <(getLocalList) <(getRemoteList)
  fi
}

function download() {
  local missing=$(getList)

  [[ -z "${missing}" ]] && {
    echo -e "$(c Ys)>> the local cache is already up to date, no need to download !$(c)"
    exit 0
  }

  counts=$(echo "${missing}" | wc -l | tr -d ' ')
  local _type=$( "${FULL_DOWNLOAD}" && echo 'full' || echo 'incremental' )
  [[ "${VERBOSE}" -ge 1 ]] && echo -e "$(c 0Wdi)>> found $(c 0Ysi)${counts} $(c 0Wdi)missing or new cheat sheets, starting ${_type} download ...$(c)" >&2

  trap 'exit 130' SIGINT SIGTERM; while read -r query; do
    [[ -z "${query}" ]] && continue

    local file fullPath url equery

    file="${query}"
    [[ "${query}" == */* ]] || file="_${query}"
    fullPath="${CS_CACHE_DIR}/${file}"
    printf -v equery "%q" "$query"
    url="https://cht.sh/${equery}"

    if "${DRY_RUN:-false}"; then
      printf "$(c Wdi).. $(c 0Gi)'%s'$(c 0Wdi) would download from $(c 0Mi)'%s'$(c 0Wdi) to $(c 0Ci)'%s'$(c)\n" "${query}" "${url}" "${fullPath}"
      continue
    fi

    [[ "${VERBOSE}" -ge 1 ]] &&
      printf "$(c 0Wdi)-- downloading: $(c 0Gi)'%s' $(c 0Wdi)to $(c 0Ci)'%s'" "${query}" "${fullPath}"
    [[ "${VERBOSE}" -ge 2 ]] && printf "$(c 0Wdi)from $(c 0Mi)'%s'" "${url}"
    [[ "${VERBOSE}" -ge 1 ]] && printf "$(c 0Wdi) %s$(c)\n" '...'

    if ! curl -g -f --create-dirs --silent --show-error --output "${fullPath}" "${url}"; then
      printf "$(c 0Rs)[FAILED] $(c 0Wdi)unable to download $(c 0Ci)'%s' $(c 0Wdi)from $(c 0Mi)'%s'$(c)\n" "${query}" "${url}" >&2

      if grep --color=never --quiet --line-regexp "Unknown topic." "${fullPath}"; then
        >&2 cat "${fullPath}"
        rm -f "${fullPath}"; exit 1;
      fi

      rm -f "${fullPath}" || true
    fi

    sleep 0.02
  done <<< "${missing}"

  echo -e "$(c Ys)DONE !$(c)"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help     ) showUsage                   ;;
    --full-download ) FULL_DOWNLOAD=true  ; shift ;;
    --update        ) FULL_DOWNLOAD=false ; shift ;;
    --sub-list      ) SUB_LIST=true       ; shift ;;
    -s | --silent   ) VERBOSE=0           ; shift ;;
    -v              ) VERBOSE=1           ; shift ;;
    -vv             ) VERBOSE=2           ; shift ;;
    --dryrun        ) DRY_RUN=true        ; shift ;;
    *               ) echo -e "$(c 0Rs)[ERROR] $(c 0Wdi)unknown option: $(c 0Ci)'%s'$(c)\n" "$1" >&2; exit 1 ;;
  esac
done

download "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
