#!/usr/bin/env bash
# shellcheck disable=SC1078,SC1079,SC2086
# =============================================================================
#     FileName : ii.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2012
#   LastChange : 2020-10-20 22:10:01
#         Desc : for iterm2
# =============================================================================

# for itmer2
function msh {
  echo -e "\\033]6;1;bg;red;brightness;176\\a"
  echo -e "\\033]6;1;bg;green;brightness;181\\a"
  echo -e "\\033]6;1;bg;blue;brightness;175\\a"
  command ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$@"
}

function tabcolor {
  case $1 in
    green)
      echo -e "\\033]6;1;bg;red;brightness;57\\a"
      echo -e "\\033]6;1;bg;green;brightness;197\\a"
      echo -e "\\033]6;1;bg;blue;brightness;77\\a"
      ;;
    red)
      echo -e "\\033]6;1;bg;red;brightness;270\\a"
      echo -e "\\033]6;1;bg;green;brightness;60\\a"
      echo -e "\\033]6;1;bg;blue;brightness;83\\a"
      ;;
    orange)
      echo -e "\\033]6;1;bg;red;brightness;227\\a"
      echo -e "\\033]6;1;bg;green;brightness;143\\a"
      echo -e "\\033]6;1;bg;blue;brightness;10\\a"
      ;;
  esac
 }

# iTerm2 tab titles
function itit {
  if [ "$1" ]; then
    # export PROMPT_COMMAND='__bp_precmd_invoke_cmd'
    unset PROMPT_COMMAND
    echo -ne "\\033]0;${1}\\007"

    if [ 2 -eq $# ]; then
      case $2 in
        [cC] )
          it2setcolor tab "$(shuf -n 1 ~/.marslo/.it2colors)" || echo
          ;;
        [bB] )
          # https://iterm2.com/documentation-badges.html
          printf "\e]1337;SetBadgeFormat=%s\a" "$(echo -n "${1} \(user.gitBranch)" | base64)"
          ;;
        [bB][cC] | [cC][bB] )
          printf "\e]1337;SetBadgeFormat=%s\a" "$(echo -n "${1}" | base64)"
          it2setcolor tab "$(shuf -n 1 ~/.marslo/.it2colors)" || echo
          ;;
      esac
    fi

  else
    export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/\~}\007";'
    printf "\e]1337;SetBadgeFormat=%s\a" "$(echo -n "" | base64)"
    it2setcolor tab default
  fi
}

function cpick() {
  if test tabset; then
    rgb=$(tabset -p | sed -nr "s:.*rgb\(([^)]+)\).*$:\1:p")
    hexc=$(for c in $(echo "${rgb}" | sed -re 's:,: :g'); do printf '%02x' "$c"; done)
    echo -e """\t$rgb ~~> $hexc"""
  fi
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
