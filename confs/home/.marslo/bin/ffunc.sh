#!/usr/bin/env bash
# shellcheck disable=SC2086
#=============================================================================
#     FileName : ffunc.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2023-12-28 12:23:43
#   LastChange : 2024-01-12 16:43:05
#  Description : [f]zf [func]tion
#=============================================================================

# /**************************************************************
#  __      __
#  / _|    / _|
# | |_ ___| |_
# |  _|_  /  _|
# | |  / /| |
# |_| /___|_|
#
# **************************************************************/

## preview contents via `$ cd **<tab>`:
# - https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/
# - https://github.com/junegunn/fzf?tab=readme-ov-file#fuzzy-completion-for-bash-and-zsh
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
            tree ) fd . --type d --hidden --follow | fzf --preview 'tree -C {}' "$@" ;;
              cd ) fzf --preview 'tree -C {} | head -200'                       "$@" ;;
    export|unset ) fzf --preview "eval 'echo \$'{}"                             "$@" ;;
               * ) fzf                                                          "$@" ;;
  esac
}

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# smart copy - using `fzf` to list files and copy the selected file
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description :
#   - if `copy` without parameter, then list file via `fzf` and copy the content
#     - "${COPY}"
#       - `pbcopy` in osx
#       - `/mnt/c/Windows/System32/clip.exe` in wsl
#   - otherwise copy the content of parameter `$1` via `pbcopy` or `clip.exe`
# shellcheck disable=SC2317
function copy() {                          # smart copy
  [[ -z "${COPY}" ]] && echo -e "$(c Rs)ERROR: 'copy' function NOT support :$(c) $(c Ri)$(uanme -v)$(c)$(c Rs). EXIT..$(c)" && return;
  if [[ 0 -eq $# ]]; then
    "${COPY}" < "$(fzf --cycle --exit-0)"
  else
    "${COPY}" < "$1"
  fi
}

# smart cat - using bat by default for cat content, respect bat options
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description :
#   - using `bat` by default if `command -v bat`
#     - using `-c` ( `c`at ) as 1st parameter, to force using `type -P cat` instead of `type -P bat`
#   - if `bat` without  paramter, then search file via `fzf` and shows via `bat`
#   - if `bat` with 1   paramter, and `$1` is directory, then search file via `fzf` from `$1` and shows via `bat`
#   - otherwise respect `bat` options, and shows via `bat`
# shellcheck disable=SC2046,SC2155
function cat() {                           # smart cat
  local fdOpt='--type f --hidden --follow --exclude .git --exclude node_modules'
  local CAT="$(type -P cat)"
  if ! uname -r | grep -q "Microsoft"; then fdOpt+=' --exec-batch ls -t'; fi
  command -v nvim >/dev/null && CAT="$(type -P bat)"

  if [[ 0 -eq $# ]]; then
    "${CAT}" --theme='gruvbox-dark' $(fd . ${fdOpt} | fzf --multi --cycle --exit-0)
  elif [[ '-c' = "$1" ]]; then
    $(type -P cat) "${@:2}"
  elif [[ 1 -eq $# ]] && [[ -d $1 ]]; then
    local target=$1;
    fd . "${target}" ${fdOpt} |
      fzf --multi --cycle --bind="enter:become(${CAT} --theme='gruvbox-dark' {+})" ;
  else
    "${CAT}" --theme='gruvbox-dark' "${@:1:$#-1}" "${@: -1}"
  fi
}

# magic vim - fzf list in recent modified order
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description :
#   - if `nvim` installed using `nvim` instead of `vim`
#     - using `-v` to force using `vim` instead of `nvim` even if nvim installed
#   - if `vim` commands without paramters, then call fzf and using vim to open selected file
#   - if `vim` commands with paramters
#       - if single paramters and parameters is directlry, then call fzf in target directory and using vim to open selected file
#       - otherwise call regular vim to open file(s)
#   - to respect fzf options by: `type -t _fzf_opts_completion >/dev/null 2>&1 && complete -F _fzf_opts_completion -o bashdefault -o default vim`
# shellcheck disable=SC2155
function vim() {                           # magic vim - fzf list in most recent modified order
  local voption
  local target
  local orgv                               # force using vim instead of nvim
  local VIM="$(type -P vim)"
  local foption='--multi --cycle '
  local fdOpt="--type f --hidden --follow --unrestricted --ignore-file $HOME/.fdignore --exclude Music"
  [[ "$(pwd)" = "$HOME" ]] && fdOpt+=' --max-depth 3'
  if ! uname -r | grep -q "Microsoft"; then fdOpt+=' --exec-batch ls -t'; fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
                 -v ) orgv=1            ; shift   ;;
        -h | --help ) voption+="$1 "    ; shift   ;;
          --version ) voption+="$1 "    ; shift   ;;
      --startuptime ) voption+="$1 $2 " ; shift 2 ;;
                -Nu ) voption+="$1 $2 " ; shift 2 ;;
              --cmd ) voption+="$1 $2 " ; shift 2 ;;
                 -* ) foption+="$1 $2 " ; shift 2 ;;
                  * ) break                       ;;
    esac
  done

  [[ 1 -ne "${orgv}" ]] && command -v nvim >/dev/null && VIM="$(type -P nvim)"

  if [[ 0 -eq $# ]] && [[ -z "${voption}" ]]; then
    fd . ${fdOpt} | fzf ${foption} --bind="enter:become(${VIM} {+})"
  elif [[ 1 -eq $# ]] && [[ -d $1 ]]; then
    [[ '.' = "${1}" ]] && target="${1}" || target=". ${1}"
    fd ${target} ${fdOpt} | fzf ${foption} --bind="enter:become(${VIM} {+})"
  else
    # shellcheck disable=SC2068
    "${VIM}" ${voption} $@
  fi
}

# v - open files in ~/.vim_mru_files       # https://github.com/junegunn/fzf/wiki/Examples#v
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description : list 10 most recently used files via fzf, and open by regular vim
function v() {                             # v - open files in ~/.vim_mru_files
  local files
  files=$( grep --color=none -v '^#' ~/.vim_mru_files |
           while read -r line; do [ -f "${line/\~/$HOME}" ] && echo "$line"; done |
           fzf-tmux -d -m -q "$*" -1
         ) &&
  vim ${files//\~/$HOME}
}

function fzfInPath() {                   # return file name via fzf in particular folder
  local fdOpt="--type f --hidden --follow --unrestricted --ignore-file $HOME/.fdignore"
  if ! uname -r | grep -q 'Microsoft'; then fdOpt+=' --exec-batch ls -t'; fi
  [[ '.' = "${1}" ]] && path="${1}" || path=". ${1}"
  eval "fd ${path} ${fdOpt} | fzf --cycle --multi ${*:2} --header 'filter in ${1} :'"
}

# magic vimdiff - using fzf list in recent modified order
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description :
#   - if any of paramters is directory, then get file path via fzf in target path first
#   - if `vimdiff` commands without parameter , then compare files in `.` and `~/.marslo`
#   - if `vimdiff` commands with 1  parameter , then compare files in current path and `$1`
#   - if `vimdiff` commands with 2  parameters, then compare files in `$1` and `$2`
#   - otherwise ( if more than 2 parameters )  , then compare files in `${*: -2:1}` and `${*: -1}` with paramters of `${*: 1:$#-2}`
#   - to respect fzf options by: `type -t _fzf_opts_completion >/dev/null 2>&1 && complete -F _fzf_opts_completion -o bashdefault -o default vimdiff`
function vimdiff() {                       # smart vimdiff
  local lFile
  local rFile
  local option
  local var

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help ) option+="$1 "   ; shift   ;;
          -* ) option+="$1 $2 "; shift 2 ;;
           * ) break                     ;;
    esac
  done

  if [[ 0 -eq $# ]]; then
    lFile=$(fzfInPath '.' "${option}")
    # shellcheck disable=SC2154
    rFile=$(fzfInPath "${iRCHOME}" "${option}")
  elif [[ 1 -eq $# ]]; then
    lFile=$(fzfInPath '.' "${option}")
    [[ -d "$1" ]] && rFile=$(fzfInPath "$1" "${option}") || rFile="$1"
  elif [[ 2 -eq $# ]]; then
    [[ -d "$1" ]] && lFile=$(fzfInPath "$1" "${option}") || lFile="$1"
    [[ -d "$2" ]] && rFile=$(fzfInPath "$2" "${option}") || rFile="$2"
  else
    var="${*: 1:$#-2}"
    [[ -d "${*: -2:1}" ]] && lFile=$(fzfInPath "${*: -2:1}") || lFile="${*: -2:1}"
    [[ -d "${*: -1}"   ]] && rFile=$(fzfInPath "${*: -1}")   || rFile="${*: -1}"
  fi

  [[ -f "${lFile}" ]] && [[ -f "${rFile}" ]] && $(type -P vim) -d ${var} "${lFile}" "${rFile}"
}

# vd - open vimdiff loaded files from ~/.vim_mru_files
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description : list 10 most recently used files via fzf, and open by vimdiff
#   - if `vd` commands without parameter, list 10 most recently used files via fzf, and open selected files by vimdiff
#   - if `vd` commands with `-a` ( [q]uiet ) parameter, list 10 most recently used files via fzf and automatic select top 2, and open selected files by vimdiff
function vd() {                            # vd - open vimdiff loaded files from ~/.vim_mru_files
  [[ 1 -eq $# ]] && [[ '-q' = "$1" ]] && opt='--bind start:select+down+select+accept' || opt=''
  # shellcheck disable=SC2046
  files=$( grep --color=none -v '^#' ~/.vim_mru_files |
           xargs -d'\n' -I_ bash -c "sed 's:\~:$HOME:' <<< _" |
           fzf --multi 3 --sync --cycle --reverse ${opt}
         ) &&
  vimdiff $(xargs <<< "${files}")
}

# shellcheck disable=SC2034,SC2316
function cdp() {                           # cdp - [c][d] to selected [p]arent directory
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

function cdf() {                           # [c][d] into the directory of the selected [f]ile
  local file
  local dir
  # shellcheck disable=SC2164
  file=$(fzf --multi --query "$1") && dir=$(dirname "${file}") && cd "${dir}"
}

function fif() {                           # [f]ind-[i]n-[f]ile
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  $(type -P rg) --files-with-matches --no-messages --hidden --follow --smart-case "$1" |
  fzf --bind 'ctrl-p:preview-up,ctrl-n:preview-down' \
      --bind "enter:become($(type -P vim) {+})" \
      --header 'CTRL-N/CTRL-P or CTRL-↑/CTRL-↓ to view contents' \
      --preview "bat --color=always --style=plain {} |
                 rg --no-line-number --colors 'match:bg:yellow' --ignore-case --pretty --context 10 \"$1\" ||
                 rg --no-line-number --ignore-case --pretty --context 10 \"$1\" {} \
                "
}

function lsps() {                          # [l]i[s]t [p]roces[s]
  (date; ps -ef) |
  fzf --bind='ctrl-r:reload(date; ps -ef)' \
      --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
      --preview='echo {}' --preview-window=down,3,wrap \
      --layout=reverse --height=80% |
  awk '{print $2}'
}

function killps() {                        # [kill] [p]roces[s]
  (date; ps -ef) |
  fzf --bind='ctrl-r:reload(date; ps -ef)' \
      --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
      --preview='echo {}' --preview-window=down,3,wrap \
      --layout=reverse --height=80% |
  awk '{print $2}' |
  xargs kill -9
}

# kns - kubectl set default namesapce
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description : using `fzf` to list all available namespaces and use the selected namespace as default
# [k]ubectl [n]ame[s]pace
function kns() {                           # [k]ubectl [n]ame[s]pace
  echo 'sms-fw-devops-ci sfw-vega sfw-alpine sfw-stellaris sfw-ste sfw-titania' |
        fmt -1 |
        fzf -1 -0 --no-sort --no-multi --prompt='namespace> ' |
        xargs -i bash -c "echo -e \"\033[1;33m~~> {}\\033[0m\";
                          kubectl config set-context --current --namespace {};
                          kubecolor config get-contexts;
                         "
}

# eclr - environment variable clear, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description : list all environment variable via `fzf`, and unset selected items
# @alternative : `$ unset ,,<TAB>`
function eclr() {                          # [e]nvironment variable [c][l]ea[r]
  while read -r _env; do
    echo -e "$(c Ys)>> unset ${_env}$(c)\n$(c Wdi).. $(eval echo \$${_env})$(c)"
    unset "${_env}"
  done < <( env |
            sed -rn 's/^([a-zA-Z0-9]+)=.*$/\1/p' |
            fzf -1 --exit-0 --no-sort --multi --prompt='env> ' --header 'TAB to select multiple items'
          )
}

# penv - print environment variable, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description : list all environment variable via `fzf`, and print values for selected items
#   - to copy via `-c`
#     - "${COPY}"
#       - `pbcopy` in osx
#       - `/mnt/c/Windows/System32/clip.exe` in wsl
#   - to respect fzf options via `type -t _fzf_opts_completion >/dev/null 2>&1 && complete -F _fzf_opts_completion -o bashdefault -o default penv`
function penv() {                          # [p]rint [e]nvironment variable
  local option
  local -a array
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c ) option+="$1 "   ; shift   ;;
      -* ) option+="$1 $2 "; shift 2 ;;
       * ) break                     ;;
    esac
  done

  option+='-1 --exit-0 --sort --multi --cycle'
  while read -r _env; do
    echo -e "$(c Ys)>> ${_env}$(c)\n$(c Wi).. $(eval echo \$${_env})$(c)"
    array+=( "${_env}=$(eval echo \$${_env})" )
  done < <( env |
            sed -r 's/^([a-zA-Z0-9_-]+)=.*$/\1/' |
            fzf ${option//-c\ /} \
                --prompt 'env> ' \
                --header 'TAB/SHIFT-TAB to select multiple items, CTRL-D to deselect-all, CTRL-S to select-all'
          )
  [[ "${option}" == *-c\ * ]] && [[ -n "${COPY}" ]] && "${COPY}" < <( printf '%s\n' "${array[@]}" | head -c-1 )
}

# mkclr - compilation environment variable clear, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description : list compilation environment variable via `fzf`, and unset for selected items
function mkclr() {                         # [m]a[k]e environment variable [c][l]ea[r]
  while read -r _env; do
    echo -e "$(c Ys)>> unset ${_env}$(c)\n$(c Wdi).. $(eval echo \$${_env})$(c)"
    unset "${_env}"
  done < <( echo 'LDFLAGS CFLAGS CPPFLAGS PKG_CONFIG_PATH LIBRARY_PATH LD_LIBRARY_PATH' |
                  fmt -1 |
                  fzf -1 --exit-0 \
                         --no-sort \
                         --multi \
                         --cycle \
                         --prompt 'env> ' \
                         --header 'TAB/SHIFT-TAB to select multiple items, CTRL-D to deselect-all, CTRL-S to select-all'
          )
  # echo -e "\n$(c Wdi)[TIP]>> to list all env via $(c)$(c Wdiu)\$ env | sed -rn 's/^([a-zA-Z0-9]+)=.*$/\1/p'$(c)"
}

# mkexp - compilation environment variable export, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description : list compilation environment variable via `fzf`, and export selected items
#   - if paramter is [ -f | --full ], then load full tool paths
# shellcheck disable=SC1090,SC2155
function mkexp() {                         # [m]a[k]e environment variable [e][x][p]ort
  local usage="$(c Cs)mkexp$(c) - $(c Cs)m$(c)a$(c Cs)k$(c)e environment $(c Cs)exp$(c)ort\n\nSYNOPSIS:
  \n\t$(c Gs)\$ mkexp [ -h | --help ]
                [ -f | --full ]"
  if [[ 1 -eq $# ]]; then
    if [[ '-h' = "$1" ]] || [[ '--help' = "$1" ]]; then
      echo -e "${usage}"
      return
    elif [[ '-f' = "$1" ]] || [[ '--full' = "$1" ]]; then
      source ~/.marslo/.imac
    fi
  fi

  LDFLAGS="${LDFLAGS:-}"
  test -d "${HOMEBREW_PREFIX}"      && LDFLAGS+=" -L${HOMEBREW_PREFIX}/lib"
  test -d '/usr/local/opt/readline' && LDFLAGS+=' -L/usr/local/opt/readline/lib'
  test -d "${OPENLDAP_HOME}"        && LDFLAGS+=" -L${OPENLDAP_HOME}/lib"
  test -d "${CURL_OPENSSL_HOME}"    && LDFLAGS+=" -L${CURL_OPENSSL_HOME}/lib"
  test -d "${BINUTILS}"             && LDFLAGS+=" -L${BINUTILS}/lib"
  test -d "${PYTHON_HOME}"          && LDFLAGS+=" -L${PYTHON_HOME}/lib"
  test -d "${RUBY_HOME}"            && LDFLAGS+=" -L${RUBY_HOME}/lib"
  test -d "${TCLTK_HOME}"           && LDFLAGS+=" -L${TCLTK_HOME}/lib"
  test -d "${SQLITE_HOME}"          && LDFLAGS+=" -L${SQLITE_HOME}/lib"
  test -d "${OPENSSL_HOME}"         && LDFLAGS+=" -L${OPENSSL_HOME}/lib"
  test -d "${NODE_HOME}"            && LDFLAGS+=" -L${NODE_HOME}/lib"                       # ${NODE_HOME}/libexec/lib for node@12
  test -d "${LIBRESSL_HOME}"        && LDFLAGS+=" -L${LIBRESSL_HOME}/lib"
  test -d "${ICU4C_711}"            && LDFLAGS+=" -L${ICU4C_711}/lib"
  test -d "${EXPAT_HOME}"           && LDFLAGS+=" -L${EXPAT_HOME}/lib"
  test -d "${NCURSES_HOME}"         && LDFLAGS+=" -L${NCURSES_HOME}/lib"
  test -d "${LIBICONV_HOME}"        && LDFLAGS+=" -L${LIBICONV_HOME}/lib"
  test -d "${ZLIB_HOME}"            && LDFLAGS+=" -L${ZLIB_HOME}/lib"
  test -d "${LLVM_HOME}"            && LDFLAGS+=" -L${LLVM_HOME}/lib"
  test -d "${LLVM_HOME}"            && LDFLAGS+=" -L${LLVM_HOME}/lib/c++ -Wl,-rpath,${LLVM_HOME}/lib/c++"  # for c++
  LDFLAGS=$( echo "$LDFLAGS" | tr ' ' '\n' | uniq | sed '/^$/d' | paste -s -d' ' )

  CFLAGS="${CFLAGS:-}"
  CFLAGS+=" -I/usr/local/include"
  test -d "${TCLTK_HOME}" && CFLAGS+=" -I${TCLTK_HOME}/include"
  CFLAGS=$( echo "$CFLAGS" | tr ' ' '\n' | uniq | sed '/^$/d' | paste -s -d' ' )

  CPPFLAGS="${CPPFLAGS:-}"
  test -d "${HOMEBREW_PREFIX}"      && CPPFLAGS+=" -I${HOMEBREW_PREFIX}/include"
  test -d "${JAVA_HOME}"            && CPPFLAGS+=" -I${JAVA_HOME}/include"
  test -d "${OPENLDAP_HOME}"        && CPPFLAGS+=" -I${OPENLDAP_HOME}/include"
  test -d "${CURL_OPENSSL_HOME}"    && CPPFLAGS+=" -I${CURL_OPENSSL_HOME}/include"
  test -d "${BINUTILS}"             && CPPFLAGS+=" -I${BINUTILS}/include"
  test -d "${SQLITE_HOME}"          && CPPFLAGS+=" -I${SQLITE_HOME}/include"
  test -d '/usr/local/opt/readline' && CPPFLAGS+=' -I/usr/local/opt/readline/include'
  test -d "${OPENSSL_HOME}"         && CPPFLAGS+=" -I${OPENSSL_HOME}/include"
  test -d "${NODE_HOME}"            && CPPFLAGS+=" -I${NODE_HOME}/include"
  test -d "${LIBRESSL_HOME}"        && CPPFLAGS+=" -I${LIBRESSL_HOME}/include"
  test -d "${TCLTK_HOME}"           && CPPFLAGS+=" -I${TCLTK_HOME}/include"
  test -d "${RUBY_HOME}"            && CPPFLAGS+=" -I${RUBY_HOME}/include"
  test -d "${ICU4C_711}"            && CPPFLAGS+=" -I${ICU4C_711}/include"
  test -d "${LLVM_HOME}"            && CPPFLAGS+=" -I${LLVM_HOME}/include"
  test -d "${LIBICONV_HOME}"        && CPPFLAGS+=" -I${LIBICONV_HOME}/include"
  test -d "${EXPAT_HOME}"           && CPPFLAGS+=" -I${EXPAT_HOME}/include"
  test -d "${NCURSES_HOME}"         && CPPFLAGS+=" -I${NCURSES_HOME}/include"
  test -d "${ZLIB_HOME}"            && CPPFLAGS+=" -I${ZLIB_HOME}/include"
  CPPFLAGS=$( echo "$CPPFLAGS" | tr ' ' '\n' | uniq | sed '/^$/d' | paste -s -d' ' )

  PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}
  PKG_CONFIG_PATH+=":${HOMEBREW_PREFIX}/lib/pkgconfig"
  test -d "${CURL_OPENSSL_HOME}"  && PKG_CONFIG_PATH+=":${CURL_OPENSSL_HOME}/lib/pkgconfig"
  test -d "${TCLTK_HOME}"         && PKG_CONFIG_PATH+=":${TCLTK_HOME}/lib/pkgconfig"
  command -v brew >/dev/null 2>&1 && PKG_CONFIG_PATH+=':/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/14'
  test -d "${SQLITE_HOME}"        && PKG_CONFIG_PATH+=":${SQLITE_HOME}/lib/pkgconfig"
  test -d "${OPENSSL_HOME}"       && PKG_CONFIG_PATH+=":${OPENSSL_HOME}/lib/pkgconfig"
  test -d "${PYTHON_HOME}"        && PKG_CONFIG_PATH+=":${PYTHON_HOME}/lib/pkgconfig"
  test -d "${RUBY_HOME}"          && PKG_CONFIG_PATH+=":${RUBY_HOME}/lib/pkgconfig"
  test -d "${LIBRESSL_HOME}"      && PKG_CONFIG_PATH+=":${LIBRESSL_HOME}/lib/pkgconfig"
  test -d "${ICU4C_711}"          && PKG_CONFIG_PATH+=":${ICU4C_711}/lib/pkgconfig"
  test -d "${EXPAT_HOME}"         && PKG_CONFIG_PATH+=":${EXPAT_HOME}/lib/pkgconfig"
  test -d "${NCURSES_HOME}"       && PKG_CONFIG_PATH+=":${NCURSES_HOME}/lib/pkgconfig"
  test -d "${ZLIB_HOME}"          && PKG_CONFIG_PATH+=":${ZLIB_HOME}/lib/pkgconfig"
  PKG_CONFIG_PATH=$( echo "$PKG_CONFIG_PATH" | tr ':' '\n' | uniq | sed '/^$/d' | paste -s -d: )

  LIBRARY_PATH="${HOMEBREW_PREFIX}/lib"
  test -d "${LIBICONV_HOME}" && LIBRARY_PATH+=":${LIBICONV_HOME}/lib"
  LIBRARY_PATH=$( echo "$LIBRARY_PATH" | tr ':' '\n' | uniq | sed '/^$/d' | paste -s -d: )

  LD_LIBRARY_PATH=/usr/local/lib
  LD_LIBRARY_PATH=$( echo "$LD_LIBRARY_PATH" | tr ':' '\n' | uniq | sed '/^$/d' | paste -s -d: )

  while read -r _env; do
    export "${_env?}"
    echo -e "$(c Ys)>> ${_env}$(c)\n$(c Wi).. $(eval echo \$${_env})$(c)"
  done < <( echo 'LDFLAGS CFLAGS CPPFLAGS PKG_CONFIG_PATH LIBRARY_PATH LD_LIBRARY_PATH' |
                  fmt -1 |
                  fzf -1 --exit-0 \
                         --no-sort \
                         --multi \
                         --cycle \
                         --prompt 'env> ' \
                         --header 'TAB/SHIFT-TAB to select multiple items, CTRL-D to deselect-all, CTRL-S to select-all'
          )
}

# imgview - fzf list and preview images
# @author      : marslo
# @source      : https://github.com/marslo/mylinux/blob/master/confs/home/.marslo/bin/ffunc.sh
# @description :
#   - to respect fzf options by: `type -t _fzf_opts_completion >/dev/null 2>&1 && complete -F _fzf_opts_completion -o bashdefault -o default imgview`
#   - disable `gif` due to imgcat performance issue
# shellcheck disable=SC2215
function imgview() {                       # view image via [imgcat](https://github.com/eddieantonio/imgcat)
  fd --unrestricted --type f --exclude .git --exclude node_modules '^*\.(png|jpeg|jpg|xpm|bmp)$' |
  fzf "$@" --height 100% \
           --preview "imgcat -W \$FZF_PREVIEW_COLUMNS -H \$FZF_PREVIEW_LINES {}" \
           --bind 'ctrl-y:execute-silent(echo -n {+} | pbcopy)+abort' \
           --header 'Press CTRL-Y to copy name into clipboard' \
           --preview-window 'down:80%:nowrap' \
           --exit-0 \
  >/dev/null || true
}

# fman - fzf list and preview for manpage:
# @source      : https://github.com/junegunn/fzf/wiki/examples#fzf-man-pages-widget-for-zsh
# @description :
#   - CTRL-N/CTRL-P or SHIFT-↑/↓ for view preview content
#   - ENTER/Q to toggle maximize/normal preview window
#   - CTRL+O  to toggle tldr in preview window
#   - CTRL+I  to toggle man in preview window
#   - CTRL+/  to toggle preview window hidden/show
#   - to respect fzf options by: `type -t _fzf_opts_completion >/dev/null 2>&1 && complete -F _fzf_opts_completion -o bashdefault -o default fman`
# shellcheck disable=SC2046
function fman() {
  unset MANPATH
  local option
  local batman="man {1} | col -bx | bat --language=man --plain --color always --theme='gruvbox-dark'"

  while [[ $# -gt 0 ]]; do
    case "$1" in
          -* ) option+="$1 $2 "; shift 2 ;;
           * ) break                     ;;
    esac
  done

  man -k . |
  sort -u |
  sed -r 's/(\(.+\))//g' |
  grep -v -E '::' |
  awk -v cyan=$(tput setaf 6) -v blue=$(tput setaf 4) -v res=$(tput sgr0) -v bld=$(tput bold) '{ $1=cyan bld $1; $2=res blue $2;} 1' |
  fzf ${option:-} \
      -d ' ' \
      --nth 1 \
      --height 100% \
      --ansi \
      --no-multi \
      --tiebreak=begin \
      --prompt='ᓆ > ' \
      --color='prompt:#0099BD' \
      --preview-window 'up,70%,wrap,rounded,<50(up,85%,border-bottom)' \
      --preview "${batman}" \
      --bind 'ctrl-p:preview-up,ctrl-n:preview-down' \
      --bind "ctrl-o:+change-preview(tldr --color {1})+change-prompt(ﳁ tldr > )" \
      --bind "ctrl-i:+change-preview(${batman})+change-prompt(ᓆ  man > )" \
      --bind "enter:execute(${batman})+change-preview(${batman})+change-prompt(ᓆ > )" \
      --bind='ctrl-/:toggle-preview' \
      --header 'CTRL-N/P or SHIFT-↑/↓ to view preview contents; ENTER/Q to maximize/normal preview window' \
      --exit-0
}

# /**************************************************************
#  _           _
# | |         | |
# | |__   __ _| |_
# | '_ \ / _` | __|
# | |_) | (_| | |_
# |_.__/ \__,_|\__|
#
# **************************************************************/

# bat
help() { "$@" --help 2>&1 | bat --plain --language=help ; }

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=marker:foldmarker=#\ **************************************************************/,#\ /**************************************************************
