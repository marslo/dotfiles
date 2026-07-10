#!/usr/bin/env bash
# shellcheck disable=SC2207,SC2034
# =============================================================================
#      FileName : ls-stgs.bash
#        Author : marslo
#       Created : 2026-06-23 22:16:41
#    LastChange : 2026-07-09 17:59:49
# =============================================================================

# bash completion for ls-stgs.sh
_ls_stgs() {
  local cur prev words cword
  _init_completion 2>/dev/null || {
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  }

  local opts='
    -d --domain
    -j --job
    -b --build
    -u --url
    -f --failure
    -a --all
    -s --steps
    -v, -vv
    -h --help
  '

  case "$prev" in
    # jenkins host
    -d|--domain ) local _psdir _f _rel _org _host _hosts=''
                  _psdir="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
                  shopt -s nullglob
                  for _f in "${_psdir}"/*/jenkins/apikey/*.gpg; do
                    _rel="${_f#"${_psdir}"/}"; _org="${_rel%%/*}"
                    _host="${_f##*/}"; _host="${_host%.gpg}"
                    _hosts+="${_host}.${_org}.com "
                  done
                  shopt -u nullglob
                  COMPREPLY=( $(compgen -W "${_hosts}" -- "${cur}") )
                  return 0 ;;
    # jenkins job name
    -j|--job    ) COMPREPLY=( $(compgen -W 'UnifiedSDK/release' -- "${cur}") ); return 0 ;;
    # full build url: free-form, no completion list
    -u|--url    ) COMPREPLY=(); return 0 ;;
    # build number
    -b|--build  ) local domain job i url builds jobpath token host first org entry
                  domain="${JENKINS_HOST:-}"
                  job='UnifiedSDK/release'
                  for ((i=1; i<COMP_CWORD; i++)); do
                    case "${COMP_WORDS[i]}" in
                      -d|--domain ) domain="${COMP_WORDS[i+1]}" ;;
                      -j|--job    ) job="${COMP_WORDS[i+1]}"    ;;
                    esac
                  done
                  [[ -z "${domain}" ]] && { COMPREPLY=(); return 0; }

                  [[ "${domain}" =~ ^https?:// ]] && url="${domain%/}" || url="https://${domain}"

                  # get entry for pass
                  host="${domain#http*://}"          # remove http(s)://
                  host="${host%%/*}"                 # remove path (/.+)
                  host="${host%%:*}"                 # remove port (:.+)
                  first="${host%%.*}"                # trim long-domain to short-domain (first part)
                  org="${host#*.}"; org="${org%%.*}" # get organization *.org.com
                  entry="${org}/jenkins/apikey/${first}"

                  token=$(pass show "${entry}" 2>/dev/null | head -1)
                  [[ -z "${token}" ]] && { COMPREPLY=(); return 0; }

                  jobpath="${job//\//\/job\/}"
                  url="${url}/job/${jobpath}/api/json?tree=builds[number]"

                  builds=$(command curl -s -g -H "X-API-Key: ${token}" "${url}" 2>/dev/null | jq -r '.builds[].number' 2>/dev/null)
                  COMPREPLY=( $(compgen -W "${builds}" -- "${cur}") )

                  return 0 ;;
  esac

 # default completion for options
  COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
  return 0
}

complete -F _ls_stgs ls-stgs.sh
complete -F _ls_stgs ls-stgs

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
