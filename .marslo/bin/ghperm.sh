#!/usr/bin/env bash
#=============================================================================
#     FileName : ghperm.sh
#       Author : marslo
#      Created : 2025-09-03 19:00:40
#   LastChange : 2025-09-03 22:06:35
#  Description : check repo permissions for github
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
  echo -e '\t-o, --org <organization> List repositories for the specified organization'
  echo -e '\t-m, --mrvl               Use personal PAT'
  echo -e '\t--srv <srv-account>      Use <srv-account> PAT. Currently, the only acceptable value is:'
  echo -e '\t                           - srv-release1'
  echo -e '\t-u, --url                Show repository URL instead of full name'
  echo -e '\t-p, --permission <perm>  Filter by permission. Acceptable value are:'
  echo -e '\t                           - admin, maintain, write, triage, read'
  echo -e '\t-h, --help               Show this help message and exit'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m | --mrvl       ) GITHUB_TOKEN="$(passToken 'marvell/marslo/github/marslo_mrvl')"; shift ;;
    -u | --url        ) SHOW_URL=true; shift ;;
    -o | --org        ) ORG="${2}"; shift 2;;
    --srv             ) case "${2:-}" in
                          'srv-release1' ) GITHUB_TOKEN="$(passToken 'marvell/re/ghe/srv-release1')" ;;
                           *             ) echo "ERROR: '${2:-<empty>}' is not acceptable for option \`--srv\`" >&2; exit 1 ;;
                        esac
                        shift 2 ;;
    -p | --permission ) arg=$(printf '%s' "${2:-}" | tr '[:upper:]' '[:lower:]');
                        case "${arg}" in
                          admin|maintain|write|triage|read ) PERM="${arg^^}" ;;
                          *                                ) echo "Error: invalid permission '${2:-<empty>} in option \`-p, --permission\`. Must be one of: admin, maintain, write, triage, read" >&2; exit 1 ;;
                        esac
                        shift 2 ;;
    -h | --help       ) usage ;;
    *                 ) echo "ERROR: Unknown option '$1'" >&2; exit 1 ;;
  esac
done

[[ -n "${ORG:-}" ]] && url="${GITHUB_API_URL}/orgs/${ORG}/repos?per_page=100&type=all" \
                    || url="${GITHUB_API_URL}/user/repos?per_page=100&type=all"

while [[ -n "${url}" ]]; do

  resp="$(curl -sS -i -H "Authorization: Bearer ${GITHUB_TOKEN}" "${url}")"
  rc=$?
  [[ "${rc}" -ne 0 ]] && { echo "ERROR: curl failed (rc=${rc}) url=${url}" >&2; exit "${rc}"; }

  statusLine="${resp%%$'\r'*}"
  httpCode="${statusLine#* }"
  httpCode="${httpCode%% *}"
  msg=''

  if [[ -z "${httpCode:-}" || "${httpCode}" -lt 200 || "${httpCode}" -ge 300 ]]; then
    headers="$( printf '%s' "${resp}" | sed -n '1,/^\r$/p' )"
    body="$( printf '%s' "${resp}" | sed '1,/^\r$/d' )"

    command -v jq >/dev/null 2>&1 && msg+="$(printf '%s' "${body}" | jq -r '.message? // empty')"

    echo -e "ERROR:\n\tHTTP: ${httpCode:-ERR}\n\turl: ${url}${msg:+\n\tmessage: ${msg}}" >&2
    exit 1
  fi

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

         def permRank(s):
           if   s=="ADMIN"    then 5
           elif s=="MAINTAIN" then 4
           elif s=="WRITE"    then 3
           elif s=="TRIAGE"   then 2
           elif s=="READ"     then 1
           else 0 end;

         .[] | select( .permissions != null )
             | . as $r
             | ( permission($r.permissions) ) as $mine
             | select( ($perm|length)==0 or permRank($mine) >= permRank(($perm|ascii_upcase)) )
             | ( permRank($mine) | tostring )
               + "\t" + $mine
               + "\t" + ( if $show=="true" then $r.html_url else $r.full_name end )
         '
  )
  LINES+=("${chunk[@]}")

  url=$(printf '%s\n' "${headers}" | awk -F'[<>]' '/rel="next"/{print $2}' || true)
done

# -- output --
printf '%s\n' "${LINES[@]}" \
  | LC_ALL=C sort -t $'\t' -k1,1nr -k3,3 \
  | cut -f2- \
  | column -t

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
