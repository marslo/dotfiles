#!/usr/bin/env bash
# shellcheck source=/dev/null
#=============================================================================
#     FileName : docker.tags.sh
#       Author : marslo
#      Created : 2026-04-15 17:41:49
#   LastChange : 2026-04-20 16:15:38
#=============================================================================

set -euo pipefail

# @credit: https://github.com/ppo/bash-colors
# shellcheck disable=SC2015,SC2059
function c() { [ $# == 0 ] && printf "\033[0m" || printf "$1" | sed 's/\(.\)/\1;/g;s/\([SDIUFNHT]\)/2\1/g;s/\([KRGYBMCW]\)/3\1/g;s/\([krgybmcw]\)/4\1/g;y/SDIUFNHTsdiufnhtKRGYBMCWkrgybmcw/12345789123457890123456701234567/;s/^\(.*\);$/\\033[\1m/g'; }

# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare -r _REGISTRY='http://registry.domain.com:5000'

# shellcheck disable=SC2155,SC2064
function getImages() {
  local PATH_URI='/v2/_catalog?n=100'
  local temp=$(mktemp --suffix='.headers')
  trap "rm -f '${temp}'" RETURN EXIT INT TERM

  {
    while [[ -n "${PATH_URI}" ]]; do
      command curl -sk -D "${temp}" "${REGISTRY}${PATH_URI}" | jq -r '.repositories[]?'
      PATH_URI=$(sed -nE 's/^[[:space:]]*[Ll]ink:.*<(.*)>; rel="next".*/\1/p' < "${temp}")
    done
  } | sort -V
}

function showTags() {
  : "${1?:image name is required}"

  local -a images=( "${@}" )
  local -r header='Accept: application/vnd.docker.distribution.manifest.v2+json'

  for image in "${images[@]}"; do
    mapfile -t tags< <(command curl -s -k "${REGISTRY}/v2/${image}/tags/list" | jq -r '(.tags // [])[]')
    # shellcheck disable=SC2155
    local info="$(c Wd)>> $(c 0Ci)${REGISTRY##*/}/$(c 0Yi)${image}$(c 0Wdi)"
    [[ "${VERBOSE}" -ge 1 ]] && info+=" • $(c 0G)${#tags[@]}$(c 0Wdi) tag(s)"

    echo -e "\n${info} <<$(c)"
    [[ ${#tags[@]} -eq 0 ]] && echo -e "$(c Wdi)<<NO TAG FOUND>>$(c)" && continue

    for tag in "${tags[@]}"; do
      shasum=$( command curl -s -H "${header}" "${REGISTRY}/v2/${image}/manifests/${tag}" | jq -r '.config.digest // empty' )
      imageId="$( awk -F':' '{print substr($2, 1, 12)}' <<< "${shasum}" )"
      created=$( command curl -sL "${REGISTRY}/v2/${image}/blobs/${shasum}" | jq  -r '.created // "UNKNOWN"' )
      echo -e "${tag}\t${created}\t${imageId}"
    done |
    command sort -k2 -r |
    command column -t -s $'\t'
  done
}

function showAll() {
  local -a all=()
  local -a invalid=()
  mapfile -t all < <(getImages)

  # re-write all array, if call with parameters, i.e. for `-t/--tags` options
  if [[ $# -gt 0 ]]; then
    mapfile -t all     < <(printf "%s\n" "${@}" | grep -Fxf   <(printf "%s\n" 'jenkins' "${all[@]}"))
    mapfile -t invalid < <(printf "%s\n" "${@}" | grep -vFxf  <(printf "%s\n" 'jenkins' "${all[@]}"))
  fi

  [[ ${#invalid[@]} -gt 0 ]] && echo -e "\n$(c Wi)~~> WARNING: $(c 0Ms)${#invalid[@]} $(c 0Wi)image(s) were not found in the registry:$(c)\n$(printf "$(c 0Mi) • %s$(c)\n" "${invalid[@]}")"
  [[ "${VERBOSE}"   -ge 1 ]] && echo -e "\n$(c Wi)~~> VERBOSE: $(c 0Ys)${#all[@]}$(c 0Wi) image(s) found in the registry $(c 0Ys)${REGISTRY##*/}$(c 0Wi):$(c)"
  [[ ${#all[@]}     -gt 0 ]] && showTags "${all[@]}"
}

declare REGISTRY=''
declare SHOW_ALL=false
declare SHOW_IMG=false
declare VERBOSE=0
declare -a IMAGES=()
# shellcheck disable=SC2155
declare -r USAGE="NAME
  $(c Ys)${ME}$(c) - Show Docker image and/or tags from a private registry

USAGE
  $(c Y)\$ ${ME} $(c G)[OPTIONS]$(c)

OPTIONS
  $(c G)-t$(c), $(c G)--tags$(c 0Mi) IMAGE$(c)          show tags for the specified image, multiple options for multiple images
  $(c G)-i$(c), $(c G)--images$(c)              list all images in the registry
  $(c G)-a$(c), $(c G)--all$(c)                 show tags for all images in the registry
  $(c G)-r$(c), $(c G)--registry$(c 0Mi) REGISTRY$(c)   docker registry URL $(c i)(default: $(c 0Mi)${_REGISTRY}$(c 0i))$(c)
  $(c G)-v$(c), $(c G)--verbose$(c)             show verbose. multiple $(c 0Gi)-v$(c) options increase verbosity
  $(c G)-h$(c), $(c G)--help$(c)                Show this help message

EXAMPLE
  $(c Y)\$ ${ME} $(c 0Gi)--tags $(c 0Mi)busybox$(c) $(c 0Gi)--tags $(c 0Mi)nginx$(c)  $(c Wdi)# show all tags for 'busybox' and 'nginx' docker image$(c)
  $(c Y)\$ ${ME} $(c 0Gi)--all$(c)                        $(c Wdi)# show all images with all tags in the private registry$(c)
"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t | --tags     ) IMAGES+=( "$2" )         ; shift 2 ;;
    -i | --images   ) SHOW_IMG=true            ; shift   ;;
    -a | --all      ) SHOW_ALL=true            ; shift   ;;
    -r | --registry ) REGISTRY="$2"            ; shift 2 ;;
    -h | --help     ) echo -e "${USAGE}"       ; exit 0  ;;
    -v | --verbose  ) VERBOSE=$(( ${#1} - 1 )) ; shift   ;;
    *               ) echo "ERROR: unknown option '$1'"; exit 1;;
  esac
done

REGISTRY="${REGISTRY:-${_REGISTRY}}"

${SHOW_IMG} && { getImages || exit $?; } || :
if ${SHOW_ALL}; then
  showAll || exit $?
elif [[ "${#IMAGES[@]}" -gt 0 ]]; then
  showAll "${IMAGES[@]}" || exit $?
fi

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
