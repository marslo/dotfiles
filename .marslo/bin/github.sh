#!/usr/bin/env bash
#=============================================================================
#     FileName : github.sh
#       Author : marslo
#      Created : 2025-09-03 19:00:40
#   LastChange : 2025-09-03 20:00:58
#=============================================================================

set -euo pipefail

# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare -r GITHUB_API_URL='https://api.github.com'
declare GITHUB_TOKEN="${GITHUB_TOKEN:-${GITHUB_API_TOKEN}}"
declare ORG=''
declare SHOW_URL=false
declare PERM=''
declare -a LINES=()

function passToken() { pass show "${1}" | head -n1; }
function usage() {
  echo -e 'USAGE:'
  echo -e "\t${ME} [OPTIONS]\n"
  echo -e 'OPTIONS:'
  echo -e '\t--org <organization>     List repositories for the specified organization'
  echo -e '\t--mrvl                   Use personal PAT'
  echo -e '\t--srv <srv-account>      Use <srv-account> PAT. Currently, the only acceptable value is "srv-release1"'
  echo -e '\t--url                    Show repository URL instead of full name'
  echo -e '\t-p, --permission <perm>  Filter by permission. Acceptable value are:'
  echo -e '\t                           - admin, maintain, write, triage, read'
  echo -e '\t-h, --help               Show this help message and exit'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mrvl            ) GITHUB_TOKEN="$(passToken 'marvell/marslo/github/marslo_mrvl')"; shift ;;
    --url             ) SHOW_URL=true; shift ;;
    --org             ) ORG="${2}"; shift 2;;
    --srv             ) shift;
                        case "${1:-}" in
                          'srv-release1' ) GITHUB_TOKEN="$(passToken 'marvell/re/ghe/srv-release1')" ;;
                           *             ) echo "ERROR: '${1:-<empty>}' is not acceptable for option \`--srv\`" >&2; exit 1        ;;
                        esac
                        shift ;;
    -p | --permission ) case "$2" in
                          admin|maintain|write|triage|read ) PERM="$2" ;;
                          * ) echo "Error: invalid permission '$2'. Must be one of: admin, maintain, push, triage, pull" >&2; exit 1 ;;
                        esac
                        shift 2
                        ;;
    -h | --help       ) usage ;;
    *                 ) echo "ERROR: Unknown option '$1'" >&2; exit 1 ;;
  esac
done

[[ -n "${ORG:-}" ]] && url="${GITHUB_API_URL}/orgs/${ORG}/repos?per_page=100&type=all" \
                    || url="${GITHUB_API_URL}/user/repos?per_page=100&type=all"

while [[ -n "${url}" ]]; do
  resp=$(curl -s -i -H "Authorization: Bearer ${GITHUB_TOKEN}" "${url}")

  headers=$(printf '%s' "${resp}" | sed -n '1,/^\r$/p')
  body=$(printf '%s' "${resp}"   | sed '1,/^\r$/d')

  # ADMIN > MAINTAIN > WRITE > TRIAGE > READ
  mapfile -t chunk < <(
    printf '%s\n' "${body}" |
      jq -r --arg show "${SHOW_URL:-false}" --arg perm "${PERM}" '
         def permission(p):
           if   p.admin     then "ADMIN"
           elif p.maintain  then "MAINTAIN"
           elif p.push      then "WRITE"
           elif p.triage    then "TRIAGE"
           elif p.pull      then "READ"
           else "NONE" end;

         .[]
         | select( .permissions != null )
         | select( $perm=="" or permission(.permissions)==($perm|ascii_upcase) )
         | permission( .permissions )
           + "\t"
           + ( if $show=="true" then .html_url else .full_name end )
         '
  )
  LINES+=("${chunk[@]}")

  url=$(printf '%s\n' "${headers}" | awk -F'[<>]' '/rel="next"/{print $2}' || true)
done

printf '%s\n' "${LINES[@]}" | LC_ALL=C sort -t $'\t' -k1,1 -k2,2 | column -t

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
