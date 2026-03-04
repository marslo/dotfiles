#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2155

set -euo pipefail

function showUsage() { echo -e "${USAGE}"; exit 0; }
# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${HOME}/.marslo/bin/bash-colors.sh" && source "${HOME}/.marslo/bin/bash-colors.sh" || { c() { :; }; }

declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare -r USAGE="USAGE:
  $(c Y)\$ ${ME} $(c 0G)[OPTIONS]$(c)

OPTIONS:
  $(c G)--update$(c)             only download missing or updated cheat sheets $(c 0Ci)(default)$(c)
  $(c G)--full-download$(c)      force full download of all cheat sheets
  $(c G)--dryrun$(c)             show what would be downloaded without actually downloading
  $(c G)-s$(c), $(c G)--silent$(c)         suppress all output except errors
  $(c G)-v$(c), $(c G)-vv$(c)              show debug information. multiple -v options increase verbosity $(c 0Ci)(max: $(c 0Mi)2$(c 0Ci), default: $(c 0Mi)1$(c 0Ci))$(c)
  $(c G)-h$(c), $(c G)--help$(c)           show this help message and exit
"

function getRemoteList() {
  echo -e "$(c Wdi)>> get remote list from $(c 0Ci)https://cht.sh/:list $(c 0Wdi)...$(c)" >&2
  # 1. NF: filter out empty lines
  # 2. !/\/$/: filter out directory entries (ending with '/')
  # 3. !/ /: filter out entries containing spaces (invalid cheat sheet names)
  # 4. !/^rfc\//: filter out entries starting with 'rfc/' (not actual cheat sheets)
  curl -fsSL -g "https://cht.sh/:list" | awk 'NF && !/\/$/ && !/ / && !/^rfc\//' | sort
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

function main() {
  local missing=$(getList)

  [[ -z "${missing}" ]] && {
    echo -e "$(c Ys)>> the local cache is already up to date, no need to download !$(c)"
    exit 0
  }

  counts=$(echo "${missing}" | wc -l | tr -d ' ')
  local _type=$( "${FULL_DOWNLOAD}" && echo 'full' || echo 'incremental' )
  [[ "${VERBOSE}" -ge 1 ]] && echo -e "$(c 0Wdi)>> found $(c 0Ysi)${counts} $(c 0Wdi)missing or new cheat sheets, starting ${_type} download ...$(c)" >&2

  while read -r query; do
    [[ -z "${query}" ]] && continue

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

  echo -e "$(c Gs)DONE !$(c)"
}

declare FULL_DOWNLOAD=false
declare VERBOSE=1
declare -r CS_CACHE_DIR="${CS_CACHE_DIR:-$HOME/.config/cht.sh}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help     ) showUsage                   ;;
    --full-download ) FULL_DOWNLOAD=true  ; shift ;;
    --update        ) FULL_DOWNLOAD=false ; shift ;;
    -s | --silent   ) VERBOSE=0           ; shift ;;
    -v              ) VERBOSE=1           ; shift ;;
    -vv             ) VERBOSE=2           ; shift ;;
    --dryrun        ) DRY_RUN=true        ; shift ;;
    *               ) echo -e "$(c 0Rs)[ERROR] $(c 0Wdi)unknown option: $(c 0Ci)'%s'$(c)\n" "$1" >&2; exit 1 ;;
  esac
done

main "$@"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
