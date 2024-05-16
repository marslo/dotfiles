#!/usr/bin/env bash

# /**************************************************************
#            _
#           | |
#   ___ ___ | | ___  _ __ ___
#  / __/ _ \| |/ _ \| '__/ __|
# | (_| (_) | | (_) | |  \__ \
#  \___\___/|_|\___/|_|  |___/
#
# @references:
#   - [WAOW! Complete explanations](https://stackoverflow.com/a/28938235/101831)
#   - [coloring functions](https://gist.github.com/inexorabletash/9122583)
#   - [ppo/bash-colors](https://github.com/ppo/bash-colors/tree/master)
#
# @credit      : https://stackoverflow.com/a/55073732/2940319
# @alternative : https://gist.github.com/marslo/8e4e1988de79957deb12f0eecec588ec
# @install     :
# ```bash
# $ echo "[[ -f \"/path/to/color-utils.sh\" ]] && source \"/path/to/color-utils.sh\" >> ~/.bashrc"
# ```
# **************************************************************/

# @author : Anthony Bourdain
# @usage  :
# - `rgbtohex 17 0 26` ==> 1001A
# - `rgbtohex -h 17 0 26` ==> #1001A
function rgbtohex () {
  addleadingzero () { awk '{if(length($0)<2){printf "0";} print $0;}';}
  if [[ ${1} == "-h" ]]; then
    r=${2}; g=${3}; b=${4};h='#';
  else
    r=${1}; g=${2}; b=${3};h='';
  fi
  r=$(echo "obase=16; ${r}" | bc | addleadingzero)
  g=$(echo "obase=16; ${g}" | bc | addleadingzero)
  b=$(echo "obase=16; ${b}" | bc | addleadingzero)
  echo "${h}${r}${g}${b}"
}

# @author : Anthony Bourdain
# @usage  :
# - `rgbto256 0 95, 135` ==> 22
function rgbto256 () {
  echo "define trunc(x){auto os;os=scale;scale=0;x/=1;scale=os;return x;};" \
    "16 + 36 * trunc(${1}/51) + 6 * trunc(${2}/51) +" \
    " trunc(${3}/51)" | bc
  # XTerm Color Number = 16 + 36 * R + 6 * G + B | 0 <= R,G,B <= 5
}

# @author : Anthony Bourdain
# @usage  :
# - `hexttorgb "11001A" ==> 17 0 26
# - `hexttorgb "#11001A" ==> 17 0 26
function hextorgb () {
  hexinput=$(echo "${1}" | tr '[:lower:]' '[:upper:]')           # uppercase-ing
  hexinput=$(echo "${hexinput}" | tr -d '#')                     # remove Hash if needed
  a=$(echo "${hexinput}" | cut -c-2)
  b=$(echo "${hexinput}" | cut -c3-4)
  c=$(echo "${hexinput}" | cut -c5-6)
  r=$(echo "ibase=16; ${a}" | bc)
  g=$(echo "ibase=16; ${b}" | bc)
  b=$(echo "ibase=16; ${c}" | bc)
  echo "${r} ${g} ${b}"
}

# Generates Truecolor Escape Sequences from Hex Strings. (remove '\\' to use)
# @author : Anthony Bourdain
# @params :
# -fg     Prints as a foreground color. (default)
# -bg     Prints as a background color.
# @usage  :
# - `trueHexPrint -fg "11001A" ==> '\e[38;2;17;0;26m'
# - `trueHexPrint -bg "11001A" ==> '\e[48;2;17;0;26m'
function trueHexPrint () {
  if [[ ${1} =~ "-fg" || ${1} =~ "-f" ]]; then
    fgbg=38; hexinput=${2};
  elif [[ ${1} =~ "-bg" || ${1} =~ "-b" ]]; then
    fgbg=48; hexinput=${2};
  else
    fgbg=38; hexinput=${1}
  fi
  hexinput=$(echo "${hexinput}" | tr '[:lower:]' '[:upper:]')  # uppercase-ing
  hexinput=$(echo "${hexinput}" | tr -d '#')                   # remove Hash if needed
  a=$(echo "${hexinput}" | cut -c-2)
  b=$(echo "${hexinput}" | cut -c3-4)
  c=$(echo "${hexinput}" | cut -c5-6)

  r=$(echo "ibase=16; ${a}" | bc)
  g=$(echo "ibase=16; ${b}" | bc)
  b=$(echo "ibase=16; ${c}" | bc)

  printf "\\\\e[%s;2;%s;%s;%sm" "${fgbg}" "${r}" "${g}" "${b}" # Remove one set of '\\' to utilize
}

# Generates 256 Color code table with RGB and Hex values
# @author : marslo
# @usage  :
# - to show specific xterm color(s) with parameter(s) :
#   ```bash
#   $ xColorTable 30
#   30  = rgb(0, 135, 135)   => #008787
#
#   $ xColorTable 32 40 88
#   32  = rgb(0, 135, 215)   => #0087D7
#   40  = rgb(0, 215, 0)     => #00D700
#   88  = rgb(135, 0, 0)     => #870000
#   ```
# - to show all 256 colors code table without parameter :
#   `$ xCodeTable`
function xColorTable() {
  declare -A COLORS
  declare -i i=16

  function _prettyPrint() {
    local _r _g _b colorCode hexCode
    colorCode="$1"
    IFS=' ' read -r _r _g _b <<< "$2"; unset IFS;
    hexCode=$(rgbtohex "${_r}" "${_g}" "${_b}")
    printf "%-3s = %-18s => %b\n" "${colorCode}" "rgb(${_r}, ${_g}, ${_b})" "$(trueHexPrint "${hexCode}")#${hexCode}\x1b[0m"
  }

  for ((r = 0; r <= 255; r+=40)); do                           # do tricolor
    for ((g = 0; g <= 255; g+=40)); do
      for ((b = 0; b <= 255; b+=40)); do
        COLORS[$i]+="$r $g $b"
        (( i++ ))
        if ((b == 0)); then b=55; fi
      done
      if ((g == 0)); then g=55; fi
    done
    if ((r == 0)); then r=55; fi
  done
  for ((m = 8; m <= 238; m+=10)); do                           # do monochrome
    COLORS[$i]+="$m $m $m"
    (( i++ ))
  done

  [[ 0 -ne "$#" ]] && output=$( echo "$@" | fmt -1) || output=$(printf "%s\n" "${!COLORS[@]}" | sort -n)
  while read -r _c; do
    _prettyPrint "${_c}" "${COLORS[${_c}]}"
  done <<< "${output}"
}

function 256colors() {
  local bar='█'                                          # ctrl+v -> u2588 ( full block )
  if uname -r | grep -q "microsoft"; then bar='▌'; fi    # ctrl+v -> u258c ( left half block )
  for i in {0..255}; do
    echo -e "\e[38;05;${i}m${bar}${i}";
  done | column -c 180 -s ' ';
  echo -e "\e[m"
}

function 256color() {
  declare c="38"
  [[ '-b' = "$1" ]] && c="48"
  [[ '-a' = "$1" ]] && c="38 48"

  for fgbg in ${c} ; do                    # foreground / background
    for color in {0..255} ; do             # colors
      # display the color
      printf "\e[${fgbg};5;%sm  %3s  \e[0m" "${color}" "${color}"
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

# @author : https://stackoverflow.com/a/69648792/2940319
# @usage  :
#   - `showcolors fg` : default
#   - `showcolors bg`
# @alternative: `ansi --color-codes`
function showcolors() {
  local row col blockrow blockcol red green blue
  local showcolor=_showcolor_${1:-fg}
  local white="\033[1;37m"
  local reset="\033[0m"

  echo -e "set foreground color: \\\\033[38;5;${white}NNN${reset}m"
  echo -e "set background color: \\\\033[48;5;${white}NNN${reset}m"
  echo -e "reset color & style:  \\\\033[0m"
  echo

  echo 16 standard color codes:
  for row in {0..1}; do
    for col in {0..7}; do
      $showcolor $(( row*8 + col )) "${row}"
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
      $showcolor $(( row*12 + col + 232 )) "${row}"
    done
    echo
  done
  echo
}

function _showcolor_fg() {
  # shellcheck disable=SC2155
  local code=$( printf %03d "$1" )
  echo -ne "\033[38;5;${code}m"
  echo -nE " $code "
  echo -ne "\033[0m"
}

function _showcolor_bg() {
  if (( $2 % 2 == 0 )); then
    echo -ne "\033[1;37m"
  else
    echo -ne "\033[0;30m"
  fi
  # shellcheck disable=SC2155
  local code=$( printf %03d "$1" )
  echo -ne "\033[48;5;${code}m"
  echo -nE " $code "
  echo -ne "\033[0m"
}

# to show $LS_COLORS: https://unix.stackexchange.com/a/52676/29178
# shellcheck disable=SC2068
function showLSColors() {
  ( # run in a subshell so it won't crash current color settings
      dircolors -b >/dev/null
      IFS=:
      for ls_color in ${LS_COLORS[@]}; do # For all colors
          color=${ls_color##*=}
          ext=${ls_color%%=*}
          echo -en "\E[${color}m${ext}\E[0m " # echo color and extension
      done
      echo
  )
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
