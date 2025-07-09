#!/usr/bin/env bash
#=============================================================================
#     FileName : set-git-user.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-06-30 21:54:24
#   LastChange : 2025-07-01 17:16:46
#=============================================================================

set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "fatal: not a git repository (or any of the parent directories): .git" >&2
  exit 128
}

# shellcheck disable=SC2155
declare -r REMOTE_URL=$( git remote get-url origin 2>/dev/null || git config --get remote.origin.url 2>/dev/null )
[[ -z "${REMOTE_URL}" ]] && { echo "fatal: no remote repository configured for 'origin'" >&2; exit 0; }

declare username=''
declare email=''
declare verbose=false
declare force=false
declare exists=true
[[ -n "$(git config --get --local user.email)" ]] && exists=true || exists=false

case "${REMOTE_URL}" in
  *github.com?marslo/* | *git@github-marslo.com:*                                 )
    username='marslo';         email='marslo.jiao@gmail.com' ;;
  *github.com?MarvellEmbeddedProcessors/* | *git@github-re.com:*                  )
    username='mrvlccsrel1';    email='srv-release1@marvell.com' ;;
  *github.com?marslojiao-mvl/* | *git@github-mvl.com:* | *github.com?mdevapraba/* )
    username='marslojiao-mvl'; email='marslo@marvell.com' ;;
  *github.com?Marvell-GHE-Sandbox/* | *git@github-mrvl.com:*                      )
    username='marslo_mrvl';    email='marslo@marvell.com' ;;
esac
found=$( [[ -n "${username}" && -n "${email}" ]] && echo true || echo false )

while [[ $# -gt 0 ]]; do
  case $1 in
    -v | --verbose ) verbose=true ;  shift ;;
    -f | --force   ) force=true   ;  shift ;;
    -*             ) echo "Unknown option: '$1'" >&2; exit 1 ;;
  esac
done
shouldUpdate=$( [[ true = "${exists}" && true != "${force}" ]] && echo false || echo true )

"${shouldUpdate}" && "${found}" && {
  git config user.name  "${username}";
  git config user.email "${email}";
}

if "${verbose}"; then
  darkGray='\033[0;2;3;37m'
  magenta='\033[0;3;35m'
  cyan='\033[0;3;36m'
  yellow='\033[0;3;33m'
  reset='\033[0m'

  ! "${shouldUpdate}" && {
      printf "${darkGray}>> git user (${yellow}%s ${darkGray}<${cyan}%s${darkGray}>) already exists in local. skip ...${reset}" "$(git config --local user.name)" "$(git config --local user.email)"
      exit 0;
    }

  [[ true = "${shouldUpdate}" && true = "${exists}" ]] && flag="${darkGray}[${magenta}FORCE${darkGray}] " || flag=''
  "${found}" \
      && printf "${darkGray}>> ${flag}git user set to: ${yellow}%s ${darkGray}<${cyan}%s${darkGray}>${reset}\n" "${username}" "${email}" \
      || printf "${darkGray}>> ${flag}git user not set, using default ${yellow}%s ${darkGray}<${cyan}%s${darkGray}>${darkGray}\n" "$(git config user.name)" "$(git config user.email)"
fi

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
