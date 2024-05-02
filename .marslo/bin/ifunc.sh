#!/usr/bin/env bash
# shellcheck disable=SC1078,SC1079,SC2086
# =============================================================================
#    FileName : ifunc.sh
#      Author : marslo.jiao@gmail.com
#     Created : 2012
#  LastChange : 2024-02-27 20:59:57
#  Description : Ifunctions
# =============================================================================

# /**************************************************************
#                   _ _               __
#                  | (_)             / _|
#   ___  _ __   ___| |_ _ __   ___  | |_ _   _ _ __   ___ ___
#  / _ \| '_ \ / _ \ | | '_ \ / _ \ |  _| | | | '_ \ / __/ __|
# | (_) | | | |  __/ | | | | |  __/ | | | |_| | | | | (__\__ \
#  \___/|_| |_|\___|_|_|_| |_|\___| |_|  \__,_|_| |_|\___|___/
#
# **************************************************************/
# shellcheck disable=SC2154,SC2086,SC1091
function mrc()     { source "${iRCHOME}"/.marslorc; }
function erc()     { command nvim "${iRCHOME}/.marslorc"; }
function take()    { mkdir -p "$1" && cd "$1" || return; }
function getperm() { find "$1" -printf '%m\t%u\t%g\t%p\n'; }
function rdiff()   { rsync -rv --size-only --dry-run "$1" "$2"; }
function rget()    { route -nv get "$@"; }
function forget()  { history -d $(( $(history | tail -n 1 | ${GREP} -oP '^ \d+') - 1 )); }
# https://unix.stackexchange.com/a/269085/29178
function color()   { for c; do printf '\e[48;5;%dm %03d ' "$c" "$c"; done; printf '\e[0m \n'; }
function trim()    { IFS='' read -r str; echo "${str}" | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//'; }
function kdev()    { kubectl config use-context kubernetes-dev;  }
function kprod()   { kubectl config use-context kubernetes-prod; }
# shellcheck disable=SC2015
function kx()      { [ "$1" ] && kubectl config use-context "$1" || kubectl config current-context ; }
function pipurl()  { pip list --format=freeze | cut -d= -f1 | xargs pip show | awk '/^Name/{printf $2} /^Home-page/{print ": "$2}' | column -t; }
function getsum    { awk '{ sum += $1 } END { print sum }' "$1"; }
## how many days since now https://tecadmin.net/calculate-difference-between-two-dates-in-bash/
function hmdays()  { usage="SYNOPSIS:\t\$ hmdays YYYY-MM-DD"; [[ 1 -ne $# ]] && echo -e "${usage}" || echo $(( ( $(date -d "$1" +%s) - $(date +%s))/(3600*24))) days; }
# https://serverfault.com/a/906310/129815
function ssl_expiry () { echo | openssl s_client -connect "${1}":443 2> /dev/null | openssl x509 -noout -enddate; }
function convert2av()  { ffmpeg -i "$1" -i "$2" -c copy -map 0:0 -map 1:0 -shortest -strict -2 "$3"; }

# /**************************************************************
#        _   _ _ _ _
#       | | (_) (_) |
#  _   _| |_ _| |_| |_ _   _
# | | | | __| | | | __| | | |
# | |_| | |_| | | | |_| |_| |
#  \__,_|\__|_|_|_|\__|\__, |
#                       __/ |
#                      |___/
#
# **************************************************************/

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

ibtoc() {
  path=${*:-}
  if [ 0 -eq $# ]; then
    # shellcheck disable=SC2124
    path="${MYWORKSPACE}/tools/git/marslo/mbook/docs"
    xargs doctoc --github \
                 --notitle \
                 --maxlevel 3 >/dev/null \
           < <( fd . "${path}" --type f --extension md --exclude SUMMARY.md --exclude README.md )
  else
    doctoc --github --maxlevel 3 "${path}"
  fi
}

# /**************************************************************
#            _
#           | |
#   ___ ___ | | ___  _ __ ___
#  / __/ _ \| |/ _ \| '__/ __|
# | (_| (_) | | (_) | |  \__ \
#  \___\___/|_|\___/|_|  |___/
#
# references:
#  - [WAOW! Complete explanations](https://stackoverflow.com/a/28938235/101831)
#  - [coloring functions](https://gist.github.com/inexorabletash/9122583)
#  - [ppo/bash-colors](https://github.com/ppo/bash-colors/tree/master)
# **************************************************************/

function 256colors() {
  local bar='█'                                          # ctrl+v -> u2588 ( full block )
  if uname -r | grep -q "microsoft"; then bar='▌'; fi  # ctrl+v -> u258c ( left half block )
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

function _showcolor_fg() {
  # shellcheck disable=SC2155
  local code=$( printf %03d $1 )
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
  local code=$( printf %03d $1 )
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

# /**************************************************************
#                          _         __             _
#                         | |       / /            | |
#  ___  ___  __ _ _ __ ___| |__    / / __ ___ _ __ | | __ _  ___ ___
# / __|/ _ \/ _` | '__/ __| '_ \  / / '__/ _ \ '_ \| |/ _` |/ __/ _ \
# \__ \  __/ (_| | | | (__| | | |/ /| | |  __/ |_) | | (_| | (_|  __/
# |___/\___|\__,_|_|  \___|_| |_/_/ |_|  \___| .__/|_|\__,_|\___\___|
#                                            | |
#                                            |_|
# tools:
# - mg  : [m]arslo   [g]rep
# - ms  : [m]arslo   [s]ed
# - ffs : [f]ind     [f]ile and [s]ort
# - fif : [f]ind     [i]n       [f]iles
# - fcf : [f]unction [c]ome     [f]rom
# **************************************************************/

function contains() {
  standard=$1
  sub=$2
  for _s in $(echo "${sub}" | fold -w1); do
    [[ ! "${standard}" =~ ${_s} ]] && return 1
  done
  return 0
}

# return 0 if found $2
function hasit() {
  standard=$1
  sub=$2
  result=1
  for _s in $(echo "${sub}" | fold -w1); do
    [[ "${standard}" =~ ${_s} ]] && result=0
  done
  return ${result}
}

# marslo grep
# shellcheck disable=SC2076
function mg() {
  set -f
  usage="""\tmg - $(c B)M$(c)ARSLO $(c M)G$(c)REP - COMBINED FIND AND GREP TO QUICK FIND KEYWORDS
  \nSYNOPSIS
  \t$(c sY)\$ mg [i|I] [f|F] [m|M] [w|W]
  \t     [a|A <num>] [b|B <num>] [c|C <num>]
  \t     [e|E <suffix>]
  \t     KEYWORD [<PATHA>]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ mg 'hello'
  \t\$ mg i 'hello' ~/.marslo
  \t\$ mg iC 3 'hello' ~/.marslo$(c)
  \nOPT
  \t$(c B)i$(c)            : ignore case
  \t$(c B)f$(c)            : find file name only
  \t$(c B)m$(c)            : find markdown only
  \t$(c B)w$(c)            : match word only
  \t$(c B)a|A <num>$(c)    : print <num> lines of trailing context after matching lines
  \t$(c B)b|B <num>$(c)    : print <num> lines of leading context before matching lines
  \t$(c B)c|C <num>$(c)    : print <num> lines of output context
  \t$(c B)e|E <suffix>$(c) : [e]xclude <suffix> (filetype)
  """

  keyword=''
  path='.'
  debug=1
  grepOpt='--color=always -n -H'
  gitOptAdditional='-E'
  name=''
  param=$( tr '[:upper:]' '[:lower:]' <<< "$1" )

  contains 'ifmwabce' "${param}"
  # shellcheck disable=SC2034
  paramValid=$?

  if [[ 0 -eq $# ]] ; then
    echo -e "${usage}"
    return
  elif [[ 1 -eq $# ]]; then
    keyword="$1"
  elif [[ 2 -eq $# ]] && [[ "$2" =~ '/' || "$2" =~ '.' ]]; then
    keyword="$1"
    path="$2"
  else
    [[ "${param}" =~ 'i' ]] && grepOpt+=' -i'            && params='threeMost'
    [[ "${param}" =~ 'w' ]] && grepOpt+=' -w'            && params='threeMost'
    [[ "${param}" =~ 'f' ]] && grepOpt+=' -l'            && params='threeMost'
    [[ "${param}" =~ 'm' ]] && name='-iname *.md'        && params='threeMost'
    [[ "${param}" =~ 'd' ]] && debug=0                   && params='threeMost'
    [[ "$1" =~ 'a'       ]] && grepOpt+=" -i -A $2"      && params='fourMost'
    [[ "$1" =~ 'b'       ]] && grepOpt+=" -i -B $2"      && params='fourMost'
    [[ "$1" =~ 'c'       ]] && grepOpt+=" -i -C $2"      && params='fourMost'
    [[ "$1" =~ 'A'       ]] && grepOpt+=" -A $2"         && params='fourMost'
    [[ "$1" =~ 'B'       ]] && grepOpt+=" -B $2"         && params='fourMost'
    [[ "$1" =~ 'C'       ]] && grepOpt+=" -C $2"         && params='fourMost'
    [[ "${param}" =~ 'e' ]] && name='-not -iname *.'"$2" && params='fourMost'

    if [ 'threeMost' == "${params}" ]; then
      [[ 2 -le $# ]] && keyword="$2"
      [[ 3 -eq $# ]] && path="$3"
    elif [ 'fourMost' == "${params}" ]; then
      [[ 3 -le $# ]] && keyword="$3"
      [[ 4 -eq $# ]] && path="$4"
    fi

  fi

  if [ -n "${keyword}" ]; then

    # shellcheck disable=SC1003
    if ! hasit '\' "${keyword}"; then
      grepOpt+=" ${gitOptAdditional}"
    fi

    # or using + instead of ; details: https://unix.stackexchange.com/a/43743/29178
    # shellcheck disable=SC2027,SC2125
    cmd=" find '${path}'"
    cmd+=" -type f"
    cmd+=" ${name}"
    cmd+=" -not -path '*.git/*'"
    cmd+=" -not -path '*node_modules/*'"
    cmd+=" -exec ${GREP} ${grepOpt} '${keyword}' {} \;"

    # find "${path}" \
         # -type f \
         # ${name} \
         # -not -path '*git/*' \
         # -not -path '*node_modules/*' \
         # -exec ${GREP} ${grepOpt} "${keyword}" {} \; ||

    [[ 0 -eq debug ]] &&
        echo -e """
          $(c G)DEBUG INFO:$(c)
                 $(c Y)\$1$(c) : $(c C)'${1}'$(c)
                 $(c Y)\$2$(c) : $(c C)'${2:-}'$(c)
                 $(c Y)\$3$(c) : $(c C)'${3:-}'$(c)
                 $(c Y)\$4$(c) : $(c C)'${4:-}'$(c)
            $(c Y)keyword$(c) : $(c C)'${keyword}'$(c)
               $(c Y)path$(c) : $(c C)'${path:-}'$(c)
            $(c Y)grepOpt$(c) : $(c C)'${grepOpt}'$(c)
                $(c Y)cmd$(c) : $(c C)\$${cmd}$(c)
         """

    eval "${cmd}" ||
         echo -e """\n$(c Y)ERROR ON COMMAND:$(c)\n\t$(c R)$ ${cmd}$(c) """

  elif [ 0 -ne $# ]; then
    echo -e "${usage}"
  fi

  set +f
}

# [f]ind [f]ile and [s]ort
# shellcheck disable=SC2089,SC2086,SC2090,SC2254
function ffs() {
  local opt=''
  local num='-10'

  while [[ $# -gt 0 ]]; do
    case "$1" in
      $(awk '{a=0}/-[0-9]+/{a=1}a' <<<$1) ) num="$1"     ; shift   ;;
                                       -g ) opt+="$1 "   ; shift   ;;
                                      -fg ) opt+="$1 "   ; shift   ;;
                                       -f ) opt+="$1 "   ; shift   ;;
                                      --* ) opt+="$1 $2 "; shift 2 ;;
                                       -* ) opt+="$1 "   ; shift   ;;
                                        * ) break                  ;;
    esac
  done

  local path=${1:-~/.marslo}
  local num=${2:-$num}
  num=${num//-/}
  local depth=${3:-}
  depth=${depth//-/}
  local option='--type f'

  if [[ "${opt}" =~ '-g ' ]]; then
    # git show --name-only --pretty="format:" -"${num}" | awk 'NF' | sort -u
    # references: https://stackoverflow.com/a/54677384/2940319
    ! [[ "${opt}" =~ '-a ' ]] && filter='--diff-filter=d' || filter=''
    git log --date=iso-local --first-parent --pretty=%cd --name-status --relative ${filter} |
        awk 'NF==1{date=$1}NF>1 && !seen[$2]++{print date,$0}' FS=$'\t' |
        head -"${num}"
  elif [[ "${opt}" =~ '-fg ' ]]; then
    # references: https://stackoverflow.com/a/63864280/2940319
    git ls-tree -r --name-only HEAD -z |
        TZ=PDT xargs -0 -I_ git --no-pager log -1 --date=iso-local --format="%ad | _" -- _ |
        sort -r |
        head -"${num}"
  elif [[ "${opt}" =~ '-f ' ]]; then
    option=${option: 1}
    [[ -n "${depth}" ]] && option="-maxdepth ${depth} ${option}"
    # shellcheck disable=SC2086
    find "${path}" ${option} \
                   -not -path '*/\.git/*' \
                   -not -path '*/node_modules/*' \
                   -not -path '*/go/pkg/*' \
                   -not -path '*/git/git*/*' \
                   -not -path '*/.marslo/utils/*' \
                   -not -path '*/.marslo/.completion/*' \
                   -printf "%10T+ | %p\n" |
    sort -r |
    head -"${num}"
  elif [[ 0 = "$#" ]]; then
    fdInRC | head -"${num}"
  else
    if [[ "${opt}}" =~ .*-t.* ]] || [[ "${opt}" =~ .*--type.* ]]; then
      option="${option//--type\ f/}"
    fi
    option="${opt} ${option} --hidden --follow --unrestricted --ignore-file ~/.fdignore --exclude .Trash"
    [[ -n "${depth}"    ]] && option="--max-depth ${depth} ${option}"
    [[ '.' != "${path}" ]] && option="${path} ${option}"
    # shellcheck disable=SC2086,SC2027
    eval """ fd . "${option}" --exec stat --printf='%y | %n\n' | sort -r | head -"${num}" """
  fi
}

# [f]ind [f]ile with [f]ind
function fff() {
  # shellcheck disable=SC1078,SC1079
  usage="""\t$(c B)f$(c)ind $(c M)f$(c)ile(s)
  \nSYNOPSIS
  \n\t$(c sY)\$ fff <FILENAME> [<PATH>]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ fff myfile.txt
  \t\$ ff myfile.txt ~/.marslo$(c)
  """

  if [ 0 -eq $# ]; then
    echo -e "${usage}"
  else
    path='.'
    [ 2 -eq $# ] && path="$2"
    find "${path}" -type f -not -path "\'*git/*\'" -iname "*${1}*"
  fi
}

# marslo sed
function ms() {
  # shellcheck disable=SC1078,SC1079
  usage="""msed - marslo sed - sed all key words in the path
  \n$(c s)SYNOPSIS$(c)
  \n\t$(c sY)\$ msed [OPT] <ORIGIN_STRING> <NEW_STRING> [PATH]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ msed mystr MY_STR
  \t$(c G)\$ msed re '^.*\(.*\).*$' 'MY_STR'
  \t\$ msed mystr MY_STR ~/.marslo$(c)
  \nOPT:
  \n\t$(c B)r$(c) : use extended regular expressions in the script
  \t$(c B)e$(c) : add the script to the commands to be executed
  """

  path='.'
  sw=''     # source word
  tw=''     # target word
  opt=''

  if [ 2 -le $# ]; then
    case $1 in
      [rR] )
        opt="${opt} -r"
        [ 3 -le $# ] && sw="$2" && tw="$3"
        [ 4 -eq $# ] && path="$4"
        ;;
      [rR][eE] | [eE][rR] )
        opt="${opt} -r -e"
        [ 3 -le $# ] && sw="$2" && tw="$3"
        [ 4 -eq $# ] && path="$4"
        ;;
      * )
        [ 2 -le $# ] && sw="$1" && tw="$2"
        [ 3 -le $# ] && path="$3"
        ;;
    esac
  fi

  if [ -n "${sw}" ] && [ -n "${tw}" ]; then
    # shellcheck disable=SC2125,SC2027
    cmd="""find "${path}" -type f -not -path "*git/*" -exec sed ${opt} \"s:${sw}:${tw}:g\" -i {} \;"""
    eval "${cmd}" ||
         echo -e """\n$(c Y)ERROR ON COMMAND:$(c)\n\t$(c R)$ ${cmd}$(c) """
  else
    echo -e "${usage}"
  fi
}

# [f]unction [c]ome [f]rom
function fcf() {
  if [[ 1 -ne $# ]] ; then
    echo 'Error : provide a function name'
  fi
  shopt -s extdebug; declare -F "$1"; shopt -u extdebug
}

# /**************************************************************
#                                              _                                      _
#                                             (_)                                    | |
#  _ __  _ __ _____  ___   _    ___ _ ____   ___ _ __ ___  _ __   ___ _ __ ___  _ __ | |_
# | '_ \| '__/ _ \ \/ / | | |  / _ \ '_ \ \ / / | '__/ _ \| '_ \ / _ \ '_ ` _ \| '_ \| __|
# | |_) | | | (_) >  <| |_| | |  __/ | | \ V /| | | | (_) | | | |  __/ | | | | | | | | |_
# | .__/|_|  \___/_/\_\\__, |  \___|_| |_|\_/ |_|_|  \___/|_| |_|\___|_| |_| |_|_| |_|\__|
# | |                   __/ |
# |_|                  |___/
#
# tools:
# - pset  : [p]roxy [s]et    -> found in im.sh
# - pclr  : [p]roxy [c]lear
# - pecho : [p]roxy [e]cho
# **************************************************************/

# [p]roxy [c]lear
function pclr(){
  pEnv="http_proxy ftp_proxy https_proxy all_proxy socks_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY SOCKS_PROXY"
  for envvar in ${pEnv}; do
    unset "${envvar}"
  done
  echo -e "$(c sM)all proxy environment variable has been removed.$(c)"
}

# [p]roxy [e]cho
function pecho(){
  pEnv="http_proxy ftp_proxy https_proxy all_proxy socks_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY SOCKS_PROXY no_proxy NO_PROXY"
  for envvar in ${pEnv}; do
    # shellcheck disable=SC2086
    printf "$(c Y)%-11s$(c) : $(c Gi)%s$(c)\n" "$envvar" "$(eval echo \$${envvar})";
  done
}

# open current path in [t]otal[cmd]
# TODO:
# - with path parameter, and using $PWD by default: https://www.ghisler.ch/board/viewtopic.php?p=426544&sid=0476b6a32aac9c2f1810db0f65624825#p426544
# - with Panel parameter, and using Left by default : `/O /S /L=<path>` or `/O /S /R=<path>`
# shellcheck disable=SC2155
function tcmd() {
  declare tc='/mnt/c/iMarslo/myprograms/totalcmd/TOTALCMD64.EXE'
  declare cygpath='/mnt/c/iMarslo/myprograms/Git/usr/bin/cygpath.exe'
  declare currentPath="$(realpath "$PWD" | sed -r 's/^\/mnt(.+)$/\1/')"
  declare cmd="${tc} '$(${cygpath} -w "${currentPath}")'"
  echo -e "$(c Wd)>>$(c) $(c Gis)${currentPath}$(c) $(c Wdi)will be opened in totalcmd ..$(c)"
  eval "${cmd}"
}

# inspired in https://github.com/sharkdp/bat/issues/2916#issuecomment-2061788871
# to enable command auto-completion, add the following line to your .bashrc
# ```
# [[ $(complete -p bat | wc -l) -gt 0 ]]  \
#   && eval "$(complete -p bat) showTODO" \
#   || complete -F _fzf_path_completion -o default -o bashdefault showTODO
# ``
function showTODO() {
  local option=''
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -* ) option+="$1 $2 " ; shift 2 ;;
    esac
  done

  while read -r _file; do
    # identify language automatically
    local lang='';
    lang="$(sed -r 's/^.+\.(.+)$/\1/' <<< $_file)";
    if ! bat --list-languages | grep -q "${lang}"; then
      test -x "${_file}" && lang='sh' || lang='txt';
    else
      lang='groovy';
    fi
    sed -ne '/TODO:/,/^\s*$/p' "${_file}" | bat -l ${lang} ${option} --file-name="${_file}";
  done < <(rg --vimgrep --with-filename 'TODO:' --color never | cut -d':' -f1 | uniq)
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=marker:foldmarker=#\ **************************************************************/,#\ /**************************************************************
