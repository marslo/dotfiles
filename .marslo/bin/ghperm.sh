#!/usr/bin/env bash
# shellcheck source=/dev/null
#=============================================================================
#     FileName : ghperm.sh
#       Author : marslo
#      Created : 2025-09-03 19:00:40
#   LastChange : 2025-12-04 02:24:09
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
declare VERBOSE=false
declare VVERBOSE=false
declare -a LINES=()

# shellcheck disable=SC2155
declare -r HERE="$( dirname "${BASH_SOURCE[0]:-$0}" )"
# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${HERE}/bash-colors.sh" && source "${HERE}/bash-colors.sh" || { c() { :; }; }

function die() {
  local exitcode=1 msg; local -a args=( "$@" ); local last="${!#}";
  [[ "${last}" =~ ^[0-9]+$ ]] && { exitcode="${last}"; unset "args[$(( ${#args[@]} - 1 ))]"; }
  msg="${args[*]}"
  echo -e "$(c Ri)ERROR$(c)$(c i): ${msg}.$(c) $(c 0Wdi)exit ...$(c)" >&2; exit "${exitcode}";
}
function passToken() { pass show "${1}" | head -n1; }
function usage() {
  echo -e "USAGE"
  echo -e "  $(c Ys)\$ ${ME} $(c 0Wdi)[$(c 0Gi)OPTIONS$(c 0Wdi)]$(c)"
  echo -e "\nOPTIONS"
  echo -e "  $(c G)-o$(c), $(c G)--org $(c 0Mi)<ORGANIZATION>$(c) list repositories for the specified organization"
  echo -e "  $(c G)-m$(c), $(c G)--mrvl$(c)               use personal PAT"
  echo -e "  $(c G)--srv $(c 0Mi)<ACCOUNT>$(c)          use service account PAT. Currently, acceptable values are:"
  echo -e "                            - $(c Mi)srv-release1$(c)"
  echo -e "                            - $(c Mi)sa-ip-sw-jenkins$(c)"
  echo -e "  $(c G)-u$(c), $(c G)--url$(c)                show repository URL instead of full name"
  echo -e "  $(c G)-p$(c), $(c G)--permission $(c 0Mi)<PERM>$(c)  filter by permission. acceptable values are:"
  echo -e "                            - $(c Mi)admin$(c), $(c Mi)maintain$(c), $(c Mi)write$(c), $(c Mi)triage$(c), $(c Mi)read$(c)"
  echo -e "  $(c G)-v$(c), $(c G)--verbose$(c)            enable verbose output"
  echo -e "  $(c G)-h$(c), $(c G)--help$(c)               show this help message and exit"
  echo -e "\nEXAMPLE"
  echo -e "  $(c 0Wdi)# list service account \`srv-release1\` has ADMIN perms in organization \`Marvell-GHE-Sandbox\`$(c)"
  echo -e "  $(c Ys)\$ ${ME} $(c 0Gi)--srv $(c 0Mi)srv-release1 $(c 0Gi)-o $(c 0Mi)Marvell-GHE-Sandbox $(c 0Gi)-p $(c 0Mi)admin$(c)"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m | --mrvl       ) GITHUB_TOKEN="$(passToken 'marvell/marslo/github/marslo_mrvl')"; shift ;;
    -u | --url        ) SHOW_URL=true; shift ;;
    -o | --org        ) ORG="${2}"; shift 2;;
    --srv             ) case "${2:-}" in
                          'srv-release1'     ) GITHUB_TOKEN="$(passToken 'marvell/re/ghe/srv-release1')" ;;
                          'sa-ip-sw-jenkins' ) GITHUB_TOKEN="$(passToken 'marvell/re/ghe/sa_ip-sw-jenkins')" ;;
                          *                  ) die "ERROR: '${2:-<empty>}' is not acceptable for option \`--srv\`";;
                        esac;
                        shift 2 ;;
    -p | --permission ) arg=$(printf '%s' "${2:-}" | tr '[:upper:]' '[:lower:]');
                        case "${arg}" in
                          admin|maintain|write|triage|read ) PERM="${arg^^}" ;;
                          *                                ) die "invalid permission '${2:-<empty>} in option \`-p, --permission\`. Must be one of: admin, maintain, write, triage, read" ;;
                        esac
                        shift 2 ;;
    -v | --verbose    ) VERBOSE=true; shift ;;
    -vv               ) VERBOSE=true; VVERBOSE=true; shift ;;
    -h | --help       ) usage ;;
    *                 ) die "unknown option '$1'"
  esac
done

[[ -z "${GITHUB_TOKEN:-}" ]] && die "GITHUB_TOKEN cannot be empty. Please set it in environment or use \`--mrvl\` or \`--srv\` option."
[[ -n "${ORG:-}" ]] && url="${GITHUB_API_URL}/orgs/${ORG}/repos?per_page=100&type=all" \
                    || url="${GITHUB_API_URL}/user/repos?per_page=100&type=all"
"${VERBOSE}" && printf "%b------------ DEBUG INFO -------------%b\n" "$(c Wdi)" "$(c)"

while [[ -n "${url}" ]]; do

  resp="$(curl -sS -i -H "Authorization: Bearer ${GITHUB_TOKEN}" "${url}")"
  rc=$?
  [[ "${rc}" -ne 0 ]] && { die "curl failed (rc=${rc}) url=${url}" "${rc}"; }

  "${VERBOSE}"  && printf "%b[DEBUG]%b %bURL%b: %s%b\n" "$(c Wdi)" "$(c)" "$(c 0Mi)" "$(c 0Wdi)" "${url}" "$(c)"
  "${VVERBOSE}" && printf "%b[DEBUG]%b %bCMD%b: %s%b\n" "$(c Wdi)" "$(c)" "$(c 0Mi)" "$(c 0Wdi)" "curl -sS -i -H \"Authorization: Bearer ${GITHUB_TOKEN}\" \"${url}\"" "$(c)"

  statusLine="${resp%%$'\r'*}"
  httpCode="${statusLine#* }"
  httpCode="${httpCode%% *}"
  msg=''

  headers=$(printf '%s' "${resp}" | sed -n '1,/^\r$/p')
  body=$(printf '%s' "${resp}"   | sed '1,/^\r$/d')

  if [[ -z "${httpCode:-}" || "${httpCode}" -lt 200 || "${httpCode}" -ge 300 ]]; then
    command -v jq >/dev/null 2>&1 && msg+="$(printf '%s' "${body}" | jq -r '.message? // empty')"
    die "\n\tHTTP: ${httpCode:-ERR}\n\turl: ${url}${msg:+\n\tmessage: ${msg}}"
  fi

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

  # get next page url from Link header
  # or -- `sed -nE 's/^[Ll]ink:.*<([^>]+)>; rel="next".*/\1/p'`
  url=$(
    printf '%s\n' "${headers}" |
    awk 'tolower($1) == "link:" && /rel="next"/ { if ( match($0, /<([^>]+)>; rel="next"/, m) ) { print m[1] } }' ||
    true
  )
done

"${VERBOSE}" && printf "%b-------------------------------------%b\n\n" "$(c Wdi)" "$(c)";

# -- output --
printf '%s\n' "${LINES[@]}" \
  | LC_ALL=C sort -t $'\t' -k1,1nr -k3,3 \
  | cut -f2- \
  | column -t

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
