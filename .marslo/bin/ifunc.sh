#!/usr/bin/env bash
# shellcheck disable=SC1078,SC1079,SC2086
# =============================================================================
#    FileName : ifunc.sh
#      Author : marslo.jiao@gmail.com
#     Created : 2012
#  LastChange : 2025-07-02 22:12:14
#  Description : ifunctions
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
# shellcheck disable=SC2015
function kx()      { [ "$1" ] && kubectl config use-context "$1" || kubectl config current-context; }
function pipurl()  { pip list --format=freeze | cut -d= -f1 | xargs -n1 pip show | awk '/^Name/{printf $2} /^Home-page/{print ": "$2}' | column -t; }
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
    fdInRC | grep -v --color=never 'git-credentials' | head -"${num}"
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
function showTODO() {
  local option='--style="grid,changes,header"'
  local isNL='true'
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -nl | --no-ln ) isNL='false'     ; shift 1 ;;
       -p | --plain ) option+=" $1"    ; shift 1 ;;
            --style ) option+=" $1"    ; shift 1 ;;
                 -* ) option+=" $1 $2" ; shift 2 ;;
    esac
  done

  rg --vimgrep --with-filename 'TODO:' --color never |
     cut -d':' -f1 |
     uniq |
     while read -r _file; do
       # identify language automatically
       local lang='';
       lang="$(sed -r 's/^.+\.(.+)$/\1/' <<< "${_file}")";
       if ! bat --list-languages | command grep -iE -q "[,:]${lang}|${lang},"; then
         # check shebang and reset to empty if shebang not found
         lang=$(sed -rn 's/^#!.*[/\ ](\w+)$/\1/p' < <(head -n1 "${_file}"));
       fi
       [[ 'true' = "${isNL}" ]] && cmd="command nl \"${_file}\"" || cmd="command cat \"${_file}\""
       sed -ne '/TODO:/,/^\s*$/p' < <(eval "${cmd}") |
           eval "bat -l ${lang:-groovy} ${option} --file-name=\"${_file}\"" ;
     done
}

function fdclean() {
  local path="$PWD"
  local pattern='.DS_*'
  local verbose=false
  local dryrun=false
  local -a cleanCmd=( command fd
                      --type f
                      --hidden
                      --follow
                      --unrestricted
                      --color=never
                      --exclude .Trash
                      --exclude "OneDrive*"
                    )

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p | --path    ) path="${2}"    ; shift 2   ;;
      -k | --pattern ) pattern="${2}" ; shift 2   ;;
      -d | --debug   ) verbose=true   ; shift     ;;
      -v | --verbose ) verbose=true   ; shift     ;;
      --dryrun       ) dryrun=true    ; shift ;;
      *              ) echo "invalid option $1" >&2 ; return 1 ;;
    esac
  done

  [[ '' = "${path}" ]] && echo -e "$(c R)Error:$(c) path is empty." && return 1
  path=$(realpath "${path}")
  cleanCmd+=(--glob "*${pattern}" "${path}")
  "${dryrun}"  && cleanCmd+=(-x echo rm) || cleanCmd+=(-x rm)
  "${verbose}" && cleanCmd+=(-vf)        || cleanCmd+=(-f)         # remove -r for file only

  echo -e "$(c Wid)>> cleaning \`${pattern}\` in $(c)$(c Mis)${path}$(c)$(c Wd) ..$(c)"
  "${verbose}" && echo -e "$(c Wid)>> [DEBUG]:$(c)\n\t$(c Yi)${cleanCmd[*]}$(c)\n"
  "${cleanCmd[@]}"
}

function clean() {
  local path="${PWD}"
  local action=''
  local verbose='false'
  local -a opt=()
  # shellcheck disable=SC2155
  local usage="""$(c Cs)clean$(c) - clean dump files in path
  \nSYNOPSIS:
  \n\t$(c Gs)\$ clean [ -h | --help ]
  \t\t[ -v | --verbose ] [ --dryrun ]
  \t\t[ -p <path> | --path <path> | -a | --all ]
  \t\t[ --dot | --ds | --lg ]$(c)
  """

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p | --path    ) path="${2}"       ; shift 2  ;;
      -a | --all     ) path="$HOME"      ; shift    ;;
      -v | --verbose ) verbose='true'    ; shift    ;;
      --dryrun       ) opt+=('--dryrun') ; shift    ;;
      --dot          ) action='dot'      ; shift    ;;
      --ds           ) action='ds'       ; shift    ;;
      --lg           ) action='lg'       ; shift    ;;
      -h | --help    ) echo -e "${usage}"           ;  return 0 ;;
      *              ) echo "invalid option $1. try \`-h\`" >&2 ;  return 1 ;;
    esac
  done

  [[ 'true' = "${verbose}" ]] && opt+=('--verbose')
  case "${action}" in
    'dot' ) eval "fdclean --path '${path}' --pattern '._*' ${opt[*]}"         ;;
    'ds'  ) eval "fdclean --path '${path}' --pattern '.DS_*' ${opt[*]}"       ;;
    'lg'  ) eval "fdclean --path '${path}' --pattern 'logback.log' ${opt[*]}" ;;
    ''    ) echo -e "$(c Ri)Error:$(c) action is empty."                       ;;
  esac
}

function md2html() {
  local title=''
  local mdfile=''
  local output=''
  local pHome="$HOME/.marslo/pandoc"
  local tDepth='4'
  local verbose='false'
  # shellcheck disable=SC2155
  local usage="""$(c Cs)md2html$(c) - convert markdown to html
  \nSYNOPSIS:
  \n\t$(c Gs)\$ md2html $(c)$(c Bis)<path/to/markdown/file>$(c)$(c Gs)
  \t\t  [ $(c)$(c Bis)-i <path/to/markdown/file>$(c)$(c Gs) | $(c Bis)--input <path/to/markdown/file>$(c)$(c Gs) ]
  \t\t  [ -h | --help ]
  \t\t  [ -o <output file> | --output <output file> ]
  \t\t  [ -t <title> | --title <title> ]
  \t\t  [ --toc-depth <n> ]
  \t\t  [ -v | --debug | --verbose ]$(c)
  """

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t | --title             ) title="${2}"       ; shift 2  ;;
      -i | --input             ) mdfile="${2}"      ; shift 2  ;;
      -o | --output            ) output="${2}"      ; shift 2  ;;
      --toc-depth              ) tDepth="${2}"      ; shift 2  ;;
      -v | --debug | --verbose ) verbose='true'     ; shift    ;;
      -h | --help              ) echo -e "${usage}" ; return 0 ;;
      *                        )
        if [[ $1 != -* ]] && [[ -z "${mdfile}" ]]; then
          mdfile="$1"
          shift 1
        else
          echo "$(c R)ERROR$(c): invalid option $1. try \`-h\`" >&2
          return 1
        fi
    esac
  done

  [[ -z "${mdfile}" ]] && echo -e "$(c R)Error:$(c) markdown file is empty. check \`-h\` for more details." && return 1
  [[ -n "${mdfile}" ]] && [[ -z "${output}" ]] && output="${mdfile%.*}.html"
  if [[ -n "${title}"  ]]; then
    title="$(sed -E 's/\b(.)/\U\1/g' <<< "${title}")"
  elif [[ -n "${output}" ]]; then
    title="$(echo "${output%.*}" | sed 's/[^a-zA-Z]/ /g' | sed -E 's/\b(.)/\U\1/g')"
  elif [[ -n "${mdfile}" ]]; then
    title="$(sed -E 's/\b(.)/\U\1/g' <<< ${mdfile%.*})"
  fi

  if [[ -n "${title}" ]]; then
    # shellcheck disable=SC1001
    sedArgs=( -i "s/\(--title: \"\)[^\"]*/\1${title}/" )
    sed "${sedArgs[@]}" "${pHome}/header.html"
    pHeader="--include-in-header ${pHome}/header.html"
    pTitle="--metadata title=\"${title}\""
  else
    pHeader=''
    pTitle=''
  fi

  cmd="pandoc -f gfm -t html5 --embed-resources --standalone"
  cmd+=" --lua-filter=${pHome}/alert.lua"
  cmd+=" ${pTitle} --metadata date=\"$(date +%Y-%m-%d)\""
  cmd+=" --toc --toc-depth=${tDepth}"
  cmd+=" --css ${pHome}/github.css --css ${pHome}/alert.css --css ${pHome}/header-footer.css"
  cmd+=" ${pHeader}"
  cmd+=" --pdf-engine=weasyprint"
  cmd+=" ${mdfile} -o ${output}"

  [[ 'true' = "${verbose}" ]] && echo -e "$(c Wid)>> [DEBUG]:$(c)\n\t$(c Yi)${cmd}$(c)"
  eval "${cmd}"

  # revert header.html
  # sed -i "s/\(--title: \"\)[^\"]*/\1Title Here/" ${pHome}/header.html
  sedArgs=( -i "s/\(--title: \"\)[^\"]*/\1Title Here/" )
  sed "${sedArgs[@]}" "${pHome}/header.html"
}

# [new] [p]ass[w]or[d]
function newpwd() {
  local level=1
  local char=32
  local pattern=''
  local clipboard=false
  local verbose=false
  local show=true
  # shellcheck disable=SC2155
  local usage='USAGE'
  usage+="\n  $(c Ys)\$ newpwd$(c) $(c 0Wdi)[ $(c 0Gi)options $(c 0Wdi)]$(c)"
  usage+='\n\nOPTIONS'
  usage+="\n  $(c G)-c$(c), $(c G)--char$(c)  $(c Mi)<number>$(c)  number of characters in the password $(c 0Wdi)( default: $(c 0Mi)${char}$(c 0Wdi) )$(c)"
  usage+="\n  $(c G)-l$(c), $(c G)--level$(c) $(c Mi)<number>$(c)  password complexity level $(c 0Wdi)( $(c 0Mi)1$(c 0Wdi)-$(c 0Mi)3$(c 0Wdi), default: $(c 0Mi)${level}$(c 0Wdi) )$(c)"
  usage+="\n  $(c G)--copy$(c)                copy the generated password to clipboard $(c 0Wdi)( default: $(c 0Mi)true$(c 0Wdi) in macOS, $(c 0Mi)false $(c 0Wdi)in Linux )$(c)"
  usage+="\n  $(c G)--no-copy$(c)             do not copy the generated password to clipboard"
  usage+="\n  $(c G)--show$(c)                show the generated password in the terminal $(c 0Wdi)( default: $(c 0Mi)true$(c 0Wdi) )$(c)"
  usage+="\n  $(c G)--no-show$(c)             do not show the generated password in the terminal"
  usage+="\n  $(c G)-v$(c), $(c G)--verbose$(c)         show verbose output $(c 0Wdi)( default: $(c 0Mi)false$(c 0Wdi) )$(c)"
  usage+="\n  $(c G)-h$(c), $(c G)--help$(c)            show this help message"
  [[ "$(uname)" == "Darwin" ]] && clipboard=true

  function die() { echo -e "$(c Ri)ERROR$(c)$(c i): $*.$(c) $(c Wdi)exit ...$(c)" >&2; }

  while [[ $# -gt 0 ]]; do
    case $1 in
      -c | --char    ) char="$2"          ; shift 2  ;;
      -l | --level   ) level="$2"         ; shift 2  ;;
      --copy         ) clipboard=true     ; shift    ;;
      --no-copy      ) clipboard=false    ; shift    ;;
      --show         ) show=true          ; shift    ;;
      --no-show      ) show=false         ; shift    ;;
      -v | --verbose ) verbose=true       ; shift    ;;
      -h | --help    ) echo -e "${usage}" ; return   ;;
      -*             ) die "$(c i)unknown option: $(c 0M)'$1'$(c 0i). try$(c) $(c 0Gi)\`\$ ${ME} -- --help\`$(c)"; return 1 ;;
      *              ) break                         ;;
    esac
  done

  case ${level} in
    1) pattern='A-Za-z0-9!@#$%^&*()'                          ;;
    2) pattern='A-Za-z0-9!@#$%^&*()?:_-~+<=>'                 ;;
    3) pattern='A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' ;;
  esac

  cmd="head /dev/urandom | tr -dc '${pattern}' | head -c '${char}' && echo"
  password=$(eval "${cmd}")

  echo -e "$(c Wdi)>> $(c 0Ys)${char} $(c 0Wdi)length password is generating $(c 0Wdi)with pattern $(c 0Msi)'${pattern}' $(c 0Wdi)..$(c)"
  "${verbose}" && echo -e "$(c Wdi)>> command: $(c 0Yi)\`${cmd}\` $(c 0Wdi)..$(c)"

  "${clipboard}" && {
    if command -v xclip &> /dev/null; then
      echo "${password}" | xclip -selection clipboard
      echo -e "$(c Wdi).. password copied to clipboard!$(c)"
    elif command -v pbcopy &> /dev/null; then
      echo -n "${password}" | pbcopy
      echo -e "$(c Wdi).. password copied to clipboard!$(c)"
    else
      echo -e "$(c Ri)no clipboard utility found. password not copied.$(c)"
      show=true
    fi
  }

  "${show}" && {
    echo -e "$(c Wdi).. $(c 0Gi)generated password: $(c 0M)${password}$(c)"
  }
}

# fdiff - diff two files with diff-so-fancy
# Usage  : fdiff <file1> <file2>
# others : git diff --no-index <file1> <file2>
#          alias fdiff="diff --old-group-format=$'\\e[0;31m%<\\e[0m' --new-group-format=$'\\e[0;31m%>\\e[0m' --unchanged-group-format=$'\\e[0;32m%=\\e[0m'"
function fdiff() {
  [[ $# -ne 2 ]] && {
    echo -e "$(c Ri)ERROR$(c): $(c i)fdiff requires exactly two file paths.$(c)"
    return 1
  }
  diff -u "${1}" "${2}" | diff-so-fancy
}

# setme - set or remove user as/from admin
# usage : setme [-a | -s | --set | --add]
#               [-r | --remote]
#               [-c | --check]
#               [-u | --user <username>]
function setme() {
  [[ 'Darwin' = $(uname -s) ]] || {
    echo -e "$(c Ri)ERROR$(c): $(c 0i)setme is only available on macOS.$(c)"
    return 1
  }

  local USER=''
  local SETUP=false
  local REMOTE=false
  local CHECK=true
  function isAdmin() { dscl . -read /Groups/admin GroupMembership | grep -qw "${1:-$(whoami)}"; }

  while [[ $# -gt 0 ]]; do
    case $1 in
      -a | -s | --set | --add ) SETUP=true  ; shift   ;;
      -r | --remote           ) REMOTE=true ; shift   ;;
      -c | --check            ) CHECK=true  ; shift   ;;
      -u | --user             ) USER="$2"   ; shift 2 ;;
      *                       ) echo "Unknown option: '$1'" >&2; return 1 ;;
    esac
  done

  USER="${USER:-$(whoami)}"

  if [[ true = "${SETUP}" ]]; then
    isAdmin "${USER}" || {
      echo -e "$(c Wdi)>> setting up standard user: $(c 0Mi)${USER} $(c 0Wdi)...$(c)"
      sudo dscl . -merge /Groups/admin GroupMembership "${USER}"
    }
  fi

  if [[ true = "${REMOTE}" ]]; then
    isAdmin "${USER}" && {
      echo -e "$(c Wdi)>> removing admin user: $(c 0Mi)${USER}$(c 0Wdi) ...$(c)"
      sudo dscl . -delete /Groups/admin GroupMembership "${USER}"
    }
  fi

  if [[ true = "${CHECK}" ]]; then
    isAdmin "${USER}" \
      && echo -e "$(c Wdi)>> $(c 0Mi)${USER}$(c 0Wdi) is an $(c 0Ci)admin $(c 0Wdi)user$(c)" \
      || echo -e "$(c Wdi)>> $(c 0Mi)${USER}$(c 0Wdi) is a $(c 0Bi)standard $(c 0Wdi)user$(c)"
  fi
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
