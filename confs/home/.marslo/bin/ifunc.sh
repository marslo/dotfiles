#!/bin/bash
# shellcheck disable=SC1078,SC1079,SC2086
# =============================================================================
#    FileName : ifunc.sh
#      Author : marslo.jiao@gmail.com
#     Created : 2012
#  LastChange : 2021-01-15 22:00:55
# =============================================================================

function take() { mkdir -p "$1" && cd "$1" || return; }
function cdls() { cd "$1" && ls; }
function cdla() { cd "$1" && la; }
function chmv() { sudo mv "$1" "$2"; sudo chown -R "$(whoami)":"$(whoami)" "$2"; }
function chcp() { sudo cp -r "$1" "$2"; sudo chown -R "$(whoami)":"$(whoami)" "$2"; }
function cha() { sudo chown -R "$(whoami)":"$(whoami)" "$1"; }
function getperm() { find "$1" -printf '%m\t%u\t%g\t%p\n'; }
function rdiff() { rsync -rv --size-only --dry-run "$1" "$2"; }
function rget() { route -nv get "$@"; }
function forget() { history -d $(( $(history | tail -n 1 | ${GREP} -oP '^ \d+') - 1 )); }
function dir755() { find . -type d -perm 0777 \( -not -path "*.git" -a -not -path "*.git/*" \) -exec sudo chmod 755 {} \; -print ; }
function file644() { find . -type f -perm 0777 \( -not -path "*.git" -a -not -path "*.git/*" \) -exec sudo chmod 644 {} \; -print; }
function convert2av() { ffmpeg -i "$1" -i "$2" -c copy -map 0:0 -map 1:0 -shortest -strict -2 "$3"; }
function zh() { zipinfo "$1" | head; }
function cleanview() { rm -rf ~/.vim/view/*; }
function copy() { /usr/bin/pbcopy < $1; }

# inspired from http://www.earthinfo.org/linux-disk-usage-sorted-by-size-and-human-readable/
function udfs {
  v='*'
  # shellcheck disable=SC2124
  [ 1 -le $# ] && v="$@"
  du -sk ${v} | sort -nr | while read -r size fname; do
    for unit in k M G T P E Z Y; do
      if [ "$size" -lt 1024 ]; then
        echo -e "${size}${unit}\\t${fname}";
        break;
      fi;
      size=$((size/1024));
    done;
  done
}

function mdiff() {
  echo -e " [${1##*/}]\\t\\t\\t\\t\\t\\t\\t[${2##*/}]"
  diff -y --suppress-common-lines "$1" "$2"
}

function dir() {
  _p=$( [ 0 -eq $# ] && echo '.' || echo "$*" )
  find . -iname "${_p}" -print0 | xargs -r0 ${LS} -altr | awk '{print; total += $5}; END {print "total size: ", total}';
}

function dir-h() {
  _p=$( [ 0 -eq $# ] && echo '.' || echo "$*" )
  find . -iname "${_p}" -exec ${LS} -lthrNF --color=always {} \;
  find . -iname "${_p}" -print0 | xargs -r0 du -csh| tail -n 1
}

function rcsync() {
  SITE="Jira Confluence Jenkins Gitlab Artifactory Sonar Slave"
  HNAME=$( hostname | tr '[:upper:]' '[:lower:]' )
  for i in $SITE; do
    CURNAME=$( echo "$i" | tr '[:upper:]' '[:lower:]' )
    if [ "$HNAME" != "$CURNAME" ]; then
      echo ------------------- "$i" ---------------------;
      pushd "$PWD" || return
      cd "/home/appadmin" || return
      rsync \
        -avzrlpgoD \
        --exclude=Tools \
        --exclude=.vim/view \
        --exclude=.vim/vimsrc \
        --exclude=.vim/cache \
        --exclude=.vim/.netrwhist \
        --exclude=.ssh/known_hosts \
        -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ' \
        .marslo .vim .vimrc .inputrc .tmux.conf .pip appadmin@"$i":~/
      popd || return
    fi
  done
}

function 256color() {
  for i in {0..255}; do
    echo -e "\e[38;05;${i}m█${i}";
  done | column -c 180 -s ' '; echo -e "\e[m"
}

function 256colors() {
  for fgbg in 38 48 ; do                   # foreground / background
    for color in {0..255} ; do             # colors
      # display the color
      printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
      # display 6 colors per lines
      if [ $(( (color + 1) % 6 )) == 4 ] ; then
        echo                               # new line
      fi
    done
    echo                                   # new line
  done
}

function 256colorsAll() {
  for clbg in {40..47} {100..107} 49 ; do  # background
    for clfg in {30..37} {90..97} 39 ; do  # foreground
      for attr in 0 1 2 4 5 7 ; do         # formatting
        # print the result
        echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
      done
      echo                                 # new line
    done
  done
}

# https://stackoverflow.com/a/69648792/2940319
# usage:
#   - `showcolors fg`
#   - `showcolors bg`
# ansi --color-codes
function showcolors() {
  local row col blockrow blockcol red green blue
  local showcolor=_showcolor256_${1:-bg}
  local white="\033[1;37m"
  local reset="\033[0m"

  echo -e "Set foreground color: \\\\033[38;5;${white}NNN${reset}m"
  echo -e "Set background color: \\\\033[48;5;${white}NNN${reset}m"
  echo -e "Reset color & style:  \\\\033[0m"
  echo

  echo 16 standard color codes:
  for row in {0..1}; do
    for col in {0..7}; do
      $showcolor $(( row*8 + col )) $row
    done
    echo
  done
  echo

  echo 6·6·6 RGB color codes:
  for blockrow in {0..2}; do
    for red in {0..5}; do
      for blockcol in {0..1}; do
        green=$(( blockrow*2 + blockcol ))
        for blue in {0..5}; do
          $showcolor $(( red*36 + green*6 + blue + 16 )) $green
        done
        echo -n "  "
      done
      echo
    done
    echo
  done

  echo 24 grayscale color codes:
  for row in {0..1}; do
    for col in {0..11}; do
      $showcolor $(( row*12 + col + 232 )) $row
    done
    echo
  done
  echo
}

function _showcolor256_fg() {
  local code=$( printf %03d $1 )
  echo -ne "\033[38;5;${code}m"
  echo -nE " $code "
  echo -ne "\033[0m"
}

function _showcolor256_bg() {
  if (( $2 % 2 == 0 )); then
    echo -ne "\033[1;37m"
  else
    echo -ne "\033[0;30m"
  fi
  local code=$( printf %03d $1 )
  echo -ne "\033[48;5;${code}m"
  echo -nE " $code "
  echo -ne "\033[0m"
}

# how may days == ddiff YYYY-MM-DD now
hmdays() {
  usage="""SYNOPSIS
  \n\t\$ hmdays YYYY-MM-DD
  \nEXAMPLE
  \n\t\$ hmdays 1987-03-08
  """

  if [ 1 -ne $# ]; then
    echo -e "${usage}"
  else
    if date +%s --date "$1" > /dev/null 2>&1; then
      echo $((($(date +%s)-$(date +%s --date "$1"))/(3600*24))) days
    else
      echo -e "${usage}"
    fi
  fi
}

ibtoc() {
  if [ 0 -eq $# ]; then
    find "${MYWORKSPACE}/tools/git/marslo/mbook/docs" \
         -iname '*.md' \
         -not -path '**/SUMMARY.md' \
         -exec doctoc --github --maxlevel 3 {} \;
  else
    doctoc --github --maxlevel 3 "$@"
  fi
}

gtoc() {
  top=$(git rev-parse --show-toplevel)
  if [ 1 -eq $# ]; then
    case $1 in
      [mM] )
        top="${top}/docs"
        ;;
    esac
  fi

  find ${top} \
       -iname '*.md' \
       -not -path '**/SUMMARY.md' \
       -exec doctoc --github --maxlevel 3 {} \;
}

# /**************************************************************
#  __      __
#  / _|    / _|
# | |_ ___| |_
# |  _|_  /  _|
# | |  / /| |
# |_| /___|_|
#
# **************************************************************/
# brew install fzf

# vim $(/usr/local/bin/fzf --height 40% --layout=reverse --multi)
# fzf --bind 'enter:become(vim {})'
function fs() { fzf --multi --bind 'enter:become(vim {+})'; }

# magic vim
function vim() {
  if [[ 0 -eq $# ]]; then
    fzf --multi --bind="enter:become($(which -a vim | head -1) {+})"
  elif [[ 1 -eq $# ]] && [[ -d $1 ]]; then
    local target=$1
    pushd . >/dev/null
    cd "${target}" || return
    fzf --multi --bind="enter:become($(which -a vim | head -1) {+})"
  else
    # shellcheck disable=SC2068
    $(which -a vim | head -1) -u $HOME/.vimrc $@
  fi
}

## preview contents via `$ cd **<tab>`: https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
# https://github.com/junegunn/fzf/wiki/examples#opening-files
fe() {
  # shellcheck disable=SC2207
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  # shellcheck disable=SC2128
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fda - including hidden directories
fda() {
  local dir
  # shellcheck disable=SC2164
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# cdp - cd to selected parent directory
cdp() {
  # shellcheck disable=SC2034,SC2316
  local declare dirs=()
  get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo $_dir; done
    else
      # shellcheck disable=SC2046
      get_parent_dirs $(dirname "$1")
    fi
  }
  # shellcheck disable=SC2155,SC2046
  local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf-tmux --tac)
  cd "$DIR" || return
}

# cdf - cd into the directory of the selected file
cdf() {
  local file
  local dir
  # shellcheck disable=SC2164
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

# find-in-file - usage: fif <searchTerm>   # using ripgrep combined with preview
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" \
    | fzf --preview "highlight -O ansi -l {} 2> /dev/null \
    | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' \
  || rg --no-line-number --ignore-case --pretty --context 10 '$1' {}"
}

# list process
lsps() {
  (date; ps -ef) |
      fzf --bind='ctrl-r:reload(date; ps -ef)' \
          --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
          --preview='echo {}' --preview-window=down,3,wrap \
          --layout=reverse --height=80% | awk '{print $2}'
}

# bat
help() { "$@" --help 2>&1 | bat --plain --language=help ; }

# v - open files in ~/.vim_mru_files       # https://github.com/junegunn/fzf/wiki/Examples#v
v() {
  local files
  files=$(grep --color=none -v '^#' ~/.vim_mru_files |
          while read -r line; do
            [ -f "${line/\~/$HOME}" ] && echo "$line"
          done | fzf-tmux -d -m -q "$*" -1) && vim ${files//\~/$HOME}
}

# vim:ts=2:sts=2:sw=2:et:ft=sh
