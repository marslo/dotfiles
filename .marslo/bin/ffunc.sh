#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2086
#=============================================================================
#     FileName : ffunc.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2023-12-28 12:23:43
#   LastChange : 2024-06-24 18:28:23
#  Description : [f]zf [func]tion
#=============================================================================

source $HOME/.marslo/bin/bash-color.sh

# /**************************************************************
#  ___        ___
#  / __)      / __)
# | |__ _____| |__
# |  __|___  )  __)
# | |   / __/| |
# |_|  (_____)_|
#
# **************************************************************/

## preview contents via `$ cd **<tab>`:
# - https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/
# - https://github.com/junegunn/fzf?tab=readme-ov-file#fuzzy-completion-for-bash-and-zsh
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
            tree ) fd . --type d --hidden --follow | fzf --height 60% --preview 'tree -C {}' "$@" ;;
              cd ) fzf --height 60% --preview 'tree -C {} | head -200' "$@" ;;
    export|unset ) fzf --height 60% --preview "eval 'echo \$'{}"       "$@" ;;
               * ) fzf                                                 "$@" ;;
  esac
}

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# /**************************************************************
#   __     __              _   _ _ _ _
#  / _|___/ _|  ___   _  _| |_(_) (_) |_ _  _
# |  _|_ /  _| |___| | || |  _| | | |  _| || |
# |_| /__|_|          \_,_|\__|_|_|_|\__|\_, |
#                                        |__/
# **************************************************************/

# smart copy - using `fzf` to list files and copy the selected file
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description :
#   - if `copy` without parameter, then list file via `fzf` and copy the content
#     - "${COPY}"
#       - `pbcopy` in osx
#       - `/mnt/c/Windows/System32/clip.exe` in wsl
#   - otherwise copy the content of parameter `$1` via `pbcopy` or `clip.exe`
# shellcheck disable=SC2317
function copy() {                          # smart copy
  [[ -z "${COPY}" ]] && echo -e "$(c Rs)ERROR: 'copy' function NOT support :$(c) $(c Ri)$(uanme -v)$(c)$(c Rs). EXIT..$(c)" && return;
  local fdOpt='--type f --hidden --follow --exclude .git --exclude node_modules'
  if ! uname -r | grep -q "Microsoft"; then fdOpt+=' --exec-batch ls -t'; fi

  if [[ 0 -eq $# ]]; then
    file=$( fd . ${fdOpt} | fzf --cycle --exit-0 ) &&
      "${COPY}" < "${file}" &&
      echo -e "$(c Wd)>>$(c) $(c Gis)${file}$(c) $(c Wdi)has been copied ..$(c)"
  elif [[ 1 -eq $# ]] && [[ -d $1 ]]; then
    local target=$1;
    file=$( fd . "${target}" ${fdOpt} | fzf --cycle --exit-0 ) &&
      "${COPY}" < "${file}" &&
      echo -e "$(c Wd)>>$(c) $(c Gis)${file}$(c) $(c Wdi)has been copied ..$(c)"
  else
    "${COPY}" < "$1" &&
      echo -e "$(c Wd)>>$(c) $(c Gis)$1$(c) $(c Wdi)has been copied ..$(c)"
  fi
}

# smart cat - using bat by default for cat content, respect bat options
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
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
  command -v bat >/dev/null && CAT="$(type -P bat)"

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

# shellcheck disable=SC2089,SC2090
function fdInRC() {
  local rcPaths="$HOME/.config/nvim $HOME/.marslo $HOME/.idlerc $HOME/.ssh"
  local fdOpt="--type f --hidden --follow --unrestricted --ignore-file $HOME/.fdignore"
  fdOpt+=' --exec stat --printf="%y | %n\n"'
  (
    eval "fd --max-depth 1 --hidden '.*rc|.*profile|.*ignore|.*gitconfig|.*credentials|.yamllint.yaml' $HOME ${fdOpt}";
    echo "${rcPaths}" | fmt -1 | xargs -r -I{} bash -c "fd . {} --exclude ss/ --exclude log/ --exclude .completion/ --exclude bin/bash-completion/ ${fdOpt}" ;
  ) |  sort -r
}

function fzfInPath() {                     # return file name via fzf in particular folder
  local fdOpt="--type f --hidden --follow --unrestricted --ignore-file $HOME/.fdignore"
  if ! uname -r | grep -q 'Microsoft'; then fdOpt+=' --exec-batch ls -t'; fi
  [[ '.' = "${1}" ]] && path="${1}" || path=". ${1}"
  eval "fd ${path} ${fdOpt} | fzf --cycle --multi ${*:2} --header 'filter in ${1} :'"
}

# runrc - filter rc files from "${rcPaths}" and source the selected item(s)
#         same series: vimrc
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : default rcPaths: ~/.marslo ~/.config/nvim ~/.*rc ~/.*profile ~/.*ignore
# shellcheck disable=SC2046,SC1090
function runrc() {                         # source rc files
  local files
  local option

  while [[ $# -gt 0 ]]; do
    case "$1" in
          -* ) option+="$1 $2 "; shift 2 ;;
           * ) break                     ;;
    esac
  done

  files=$( fdInRC |
           sed -rn 's/^[^|]* \| (.+)$/\1/p' |
           fzf ${option:-} --multi --cycle \
               --marker='✓' \
               --bind "ctrl-y:execute-silent(echo -n {+} | ${COPY})+abort" \
               --header 'Press CTRL-Y to copy name into clipboard'
         )
  [[ -n "${files}" ]] &&
    source $(xargs -r <<< "${files}") &&
    echo -e "$(c Wd)>>$(c) $(c Mis)$(xargs -r -I{} bash -c "basename {}" <<< ${files} | awk -v d=', ' '{s=(NR==1?s:s d)$0}END{print s}')$(c) $(c Wdi)have been sourced ..$(c)"
}

# fman - fzf list and preview for manpage
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
  local option='-e '
  local batman="man {1} | col -bx | bat --language=man --plain --color always --theme='gruvbox-dark'"

  while [[ $# -gt 0 ]]; do
    case "$1" in
          -* ) option+="$1 $2 "; shift 2 ;;
           * ) break                     ;;
    esac
  done

  man -k . |
  sort -u |
  awk -F"(\\\([0-9]\\\),?)" '{ for(i=1;i<NF;i++) { sub(/ +/, "", $i); sub(/ +-? +/, "", $NF); if (length($i) != 0) printf ("%s - %s\n", $i, $NF) } }' |
  grep -v -E '::' |
  awk -v cyan=$(tput setaf 6) -v blue=$(tput setaf 4) -v res=$(tput sgr0) -v bld=$(tput bold) '{ $1=cyan bld $1; $2=res blue $2;} 1' |
  fzf ${option:-} \
      -d ' ' \
      --nth 1 \
      --height 100% \
      --ansi \
      --no-multi \
      --tiebreak=begin \
      --prompt='ᓆ ‣ ' \
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

# imgview - fzf list and preview images
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
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

# https://github.com/junegunn/fzf/wiki/Examples#bookmarks
# shellcheck disable=SC2016
function b() {                             # chrome [b]ookmarks browser with jq
  if [ "$(uname)" = "Darwin" ]; then
    if [[ -e "$HOME/Library/Application Support/Google/Chrome Canary/Default/Bookmarks" ]]; then
      bookmarks_path="$HOME/Library/Application Support/Google/Chrome Canary/Default/Bookmarks"
    else
      bookmarks_path="$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
    fi
    open=open
  else
    bookmarks_path="$HOME/.config/google-chrome/Default/Bookmarks"
    open=xdg-open
  fi

  jq_script='
     def ancestors: while(. | length >= 2; del(.[-1,-2]));
     . as $in | paths(.url?) as $key | $in | getpath($key) | {name,url, path: [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse | join("/") } | .path + "/" + .name + "\t" + .url'

  urls=$( jq -r "${jq_script}" < "${bookmarks_path}" \
             | sed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' \
             | fzf --ansi \
             | cut -d$'\t' -f2
        )
  # shellcheck disable=SC2046
  [[ -z "${urls}" ]] || "${open}" $(xargs -r <<< "${urls}")
}

# /**************************************************************
#   __     __                               __ _ _
#  / _|___/ _|  ___   ___ _ __  ___ _ _    / _(_) |___
# |  _|_ /  _| |___| / _ \ '_ \/ -_) ' \  |  _| | / -_)
# |_| /__|_|         \___/ .__/\___|_||_| |_| |_|_\___|
#                        |_|
#
# **************************************************************/

# magic vim - fzf list in recent modified order
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
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
                 -c ) voption+="$1 $2"  ; shift   ;;
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
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : list 10 most recently used files via fzf, and open by regular vim
function v() {                             # v - open files in ~/.vim_mru_files
  local files
  files=$( grep --color=none -v '^#' ~/.vim_mru_files |
           while read -r line; do [ -f "${line/\~/$HOME}" ] && echo "$line"; done |
           fzf-tmux -d -m -q "$*" -1
         ) &&
  vim ${files//\~/$HOME}
}

# vimr - open files by [vim] in whole [r]epository
#        same series: [`cdr`](https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh#L411-L419)
#        similar with [`:Gfiles`](https://github.com/junegunn/fzf.vim?tab=readme-ov-file#commands)
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description :
#   - if pwd inside the repo, then filter all files within current git repository via data modified and open by vim
#   - if pwd not inside the repo, then call `vim`
function vimr() {                          # vimr - open file(s) via [vim] in whole [r]epository
  local repodir
  isrepo=$(git rev-parse --is-inside-work-tree >/dev/null 2>&1; echo $?)
  if [[ 0 = "${isrepo}" ]]; then
    repodir="$(git rev-parse --show-toplevel)"
    # shellcheck disable=SC2164
    files=$( fd . "${repodir}" --type f --hidden --ignore-file ~/.fdignore --exec-batch ls -t |
                  xargs -r -I{} bash -c "echo {} | sed \"s|${repodir}/||g\"" |
                  fzf --multi -0 |
                  xargs -r -I{} bash -c "echo ${repodir}/{}"
           )
    # shellcheck disable=SC2046
    [[ -z "${files}" ]] || vim $(xargs -r <<< "${files}")
  else
    vim
  fi
}

# vimrc - open rc files list from "${rcPaths}" to quick update/modify rc files
#         same series: runrc
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description :
#   - default rcPaths: ~/.marslo ~/.config/nvim ~/.*rc ~/.*profile ~/.*ignore
#   - using nvim if `command -v nvim` is true
#   - using `-v` force using `command vim` instead of `command nvim`
# shellcheck disable=SC2155
function vimrc() {                         # vimrc - fzf list all rc files in data modified order
  local orgv                               # force using vim instead of nvim
  local rcPaths="$HOME/.config/nvim $HOME/.marslo"
  local VIM="$(type -P vim)"
  local foption='--multi --cycle '
  local fdOpt="--type f --hidden --follow --unrestricted --ignore-file $HOME/.fdignore"
  if ! uname -r | grep -q "Microsoft"; then fdOpt+=' --exec-batch ls -t'; fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v ) orgv=1 ; shift ;;
       * ) break          ;;
    esac
  done

  [[ 1 -ne "${orgv}" ]] && command -v nvim >/dev/null && VIM="$(type -P nvim)"
  fdInRC | sed -rn 's/^[^|]* \| (.+)$/\1/p' \
         | fzf ${foption} --bind="enter:become(${VIM} {+})" \
                          --bind "ctrl-y:execute-silent(echo -n {+} | ${COPY})+abort" \
                          --header 'Press CTRL-Y to copy name into clipboard'
}

# magic vimdiff - using fzf list in recent modified order
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
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
    rFile=$(fdInRC | sed -rn 's/^[^|]* \| (.+)$/\1/p' | fzf --cycle --multi ${option} --header 'filter in rc paths:')
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
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : list 10 most recently used files via fzf, and open by vimdiff
#   - if `vd` commands without parameter, list 10 most recently used files via fzf, and open selected files by vimdiff
#   - if `vd` commands with `-a` ( [q]uiet ) parameter, list 10 most recently used files via fzf and automatic select top 2, and open selected files by vimdiff
function vd() {                            # vd - open vimdiff loaded files from ~/.vim_mru_files
  [[ 1 -eq $# ]] && [[ '-q' = "$1" ]] && opt='--bind start:select+down+select+accept' || opt=''
  # shellcheck disable=SC2046
  files=$( grep --color=none -v '^#' ~/.vim_mru_files |
           xargs -r -d'\n' -I_ bash -c "sed 's:\~:$HOME:' <<< _" |
           fzf --multi 3 --sync --cycle --reverse ${opt}
         ) &&
  vimdiff $(xargs -r <<< "${files}")
}


# /**************************************************************
#   __     __                    _                    _   _
#  / _|___/ _|  ___   __ _ ___  | |_ ___   _ __  __ _| |_| |_
# |  _|_ /  _| |___| / _` / _ \ |  _/ _ \ | '_ \/ _` |  _| ' \
# |_| /__|_|         \__, \___/  \__\___/ | .__/\__,_|\__|_||_|
#                    |___/                |_|
#
# **************************************************************/

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

function cdd() {                           # cdd - [c][d] to selected sub [d]irectory
  local dir
  # shellcheck disable=SC2164
  dir=$(fd --type d --hidden --ignore-file ~/.fdignore | fzf --no-multi -0) && cd "${dir}"
}

function cdr() {                           # cdd - [c][d] to selected [r]epo directory - same series: `vimr`
  local repodir
  repodir="$(git rev-parse --show-toplevel)"
  # shellcheck disable=SC2164
  dir=$( ( echo './'; fd . "${repodir}" --type d --hidden --ignore-file ~/.fdignore |
                     xargs -r -I{} bash -c "echo {} | sed \"s|${repodir}/||g\""
         ) | fzf --no-multi -0
       ) && cd "${repodir}/${dir}"
}

function cdf() {                           # [c][d] into the directory of the selected [f]ile
  local file
  local dir
  # shellcheck disable=SC2164
  file=$(fzf --multi --query "$1") && dir=$(dirname "${file}") && cd "${dir}"
}

# references:
# - https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-the-secondary-filter
# - https://github.com/junegunn/fzf/issues/3572#issuecomment-1887735150
# shellcheck disable=SC2154
function fif() {                           # [f]ind-[i]n-[f]ile
  if [ ! "$#" -gt 0 ]; then
    bash "${iRCHOME}"/bin/rfv
  else
    $(type -P rg) --files-with-matches --no-messages --hidden --follow --smart-case "$1" |
    fzf --height 80% \
        --bind 'ctrl-p:preview-up,ctrl-n:preview-down' \
        --bind "enter:become($(type -P vim) {+})" \
        --header 'CTRL-N/CTRL-P or CTRL-↑/CTRL-↓ to view contents' \
        --preview "bat --color=always --style=plain {} |
                   rg --no-line-number --colors 'match:bg:yellow' --ignore-case --pretty --context 10 \"$1\" ||
                   rg --no-line-number --ignore-case --pretty --context 10 \"$1\" {} \
                  "
  fi
}

# /**************************************************************
#   __     __
#  / _|___/ _|  ___   _ __ _ _ ___  __ ___ ______
# |  _|_ /  _| |___| | '_ \ '_/ _ \/ _/ -_|_-<_-<
# |_| /__|_|         | .__/_| \___/\__\___/__/__/
#                    |_|
#
# **************************************************************/
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
  xargs -r kill -9
}

# /**************************************************************
#   __     __
#  / _|___/ _|  ___   ___ _ ___ __ __ ____ _ _ _
# |  _|_ /  _| |___| / -_) ' \ V / \ V / _` | '_|
# |_| /__|_|         \___|_||_\_/   \_/\__,_|_|
#
# **************************************************************/

# eclr - environment variable clear, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : list all environment variable via `fzf`, and unset selected items
# @alternative : `$ unset ,,<TAB>`
# @dependency  : https://github.com/ppo/bash-colors/blob/master/bash-colors.sh (v0.3.0)
# shellcheck disable=SC2016
function eclr() {                          # [e]nvironment variable [c][l]ea[r]
  while read -r _env; do
    echo -e "$(c Ys)>> unset ${_env}$(c)\n$(c Wdi).. $(eval echo \$${_env})$(c)"
    unset "${_env}"
  done < <( env |
            sed -r 's/^([a-zA-Z0-9_-]+)=.*$/\1/' |
            fzf -1 \
                --exit-0 \
                --layout default \
                --no-sort \
                --multi \
                --height '50%' \
                --prompt 'env> ' \
                --preview-window 'top,30%,wrap,rounded' \
                --preview 'source ~/.marslo/bin/bash-color.sh; _env={}; echo -e "$(c Gs)${_env}=${!_env}$(c)"' \
                --header 'TAB to select multiple items'
          )
}

# penv - print environment variable, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @dependency  : https://github.com/ppo/bash-colors/blob/master/bash-colors.sh (v0.3.0)
# @description : list all environment variable via `fzf`, and print values for selected items
#   - to copy via `-c`
#     - "${COPY}"
#       - `pbcopy` in osx
#       - `/mnt/c/Windows/System32/clip.exe` in wsl
#   - to respect fzf options via `type -t _fzf_opts_completion >/dev/null 2>&1 && complete -F _fzf_opts_completion -o bashdefault -o default penv`
# shellcheck disable=SC2215,SC2016
function penv() {                          # [p]rint [env]ironment variable
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
  _echo_values() { echo -e "$(c Ys)>> $1$(c)\n$(c Wi).. $(eval echo \$$1)$(c)"; }

  while read -r _env; do
    _echo_values $_env
    array+=( "${_env}=$(eval echo \$${_env})" )
  done < <( env |
            sed -r 's/^([a-zA-Z0-9_-]+)=.*$/\1/' |
            fzf ${option//-c\ /} \
                --layout default \
                --prompt 'env> ' \
                --height '50%' \
                --preview-window 'top,50%,wrap,rounded' \
                --preview 'source ~/.marslo/bin/bash-color.sh; _env={}; echo -e "$(c Gs)${_env}=${!_env}$(c)"' \
                --header 'TAB/SHIFT-TAB to select multiple items, CTRL-D to deselect-all, CTRL-S to select-all'
          )
  [[ "${option}" == *-c\ * ]] && [[ -n "${COPY}" ]] && "${COPY}" < <( printf '%s\n' "${array[@]}" | head -c-1 )
}

# mkclr - compilation environment variable clear, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : list compilation environment variable via `fzf`, and unset for selected items
# shellcheck disable=SC2016
function mkclr() {                         # [m]a[k]e environment variable [c][l]ea[r]
  while read -r _env; do
    echo -e "$(c Ys)>> unset ${_env}$(c)\n$(c Wdi).. $(eval echo \$${_env})$(c)"
    unset "${_env}"
  done < <( echo 'LDFLAGS CFLAGS CPPFLAGS PKG_CONFIG_PATH LIBRARY_PATH LD_LIBRARY_PATH' |
                  fmt -1 |
                  fzf -1 --exit-0 \
                         --layout default \
                         --no-sort \
                         --multi \
                         --cycle \
                         --prompt 'env> ' \
                         --height '50%' \
                         --preview-window 'top,50%,wrap,rounded' \
                         --preview 'source ~/.marslo/bin/bash-color.sh; _env={}; echo -e "$(c Gs)${_env}=${!_env}$(c)"' \
                         --header 'TAB/SHIFT-TAB to select multiple items, CTRL-D to deselect-all, CTRL-S to select-all'
          )
  # echo -e "\n$(c Wdi)[TIP]>> to list all env via $(c)$(c Wdiu)\$ env | sed -rn 's/^([a-zA-Z0-9]+)=.*$/\1/p'$(c)"
}

# mkexp - compilation environment variable export, support multiple select
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
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


# avpw - select and export the environment variable for ansible vault
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# shellcheck disable=SC2155
function avpw() {                          # [a]nsible [v]ault [p]ass[w]ord
  local _file=$(fd . ~/.marslo/.vault --type f --max-depth 1 --color never | xargs -I%% bash -c "name=\$(basename %%); echo \${name%.*}" | fzf)
  [[ -n "${_file}" ]] &&
    export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.marslo/.vault/${_file}.txt" &&
    echo -e "$(c Wd)>>$(c) $(c Gis)${_file}$(c) $(c Wdi)has been exported ..$(c)" &&
    penv -q ANSIBLE_VAULT_PASSWORD_FILE
}

# /**************************************************************
#   __     __         _        _                      _
#  / _|___/ _|  ___  | |___  _| |__  ___ _ _ _ _  ___| |_ ___ ___
# |  _|_ /  _| |___| | / / || | '_ \/ -_) '_| ' \/ -_)  _/ -_|_-<
# |_| /__|_|         |_\_\\_,_|_.__/\___|_| |_||_\___|\__\___/__/
#
# **************************************************************/

# kns - kubectl set default namespace, show pods and sts in preview window dynamically
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : using `fzf` to list all available namespaces and use the selected namespace as default
# @usage       : $ kns [-st] [pods | sts | ...]
# [k]ubectl [n]ame[s]pace
function kns() {                           # [k]ubectl [n]ame[s]pace
  local outputSt
  local resources

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --st | -st ) outputSt='true' ; shift 1 ;;
               * ) break                     ;;
    esac
  done

  resources=$*
  namespace=$(command kubectl config view --minify -o jsonpath='{..namespace}')
  context=$(command kubectl config current-context | sed 's/-context$//')
  newns=$(echo 'namespace_1 namespace_2 namespace_3 namespace_4' |
                fmt -1 |
                rg --color=always --colors match:fg:142 --passthru "^${namespace}$" |
                fzf -1 -0 \
                    --no-sort \
                    --no-multi \
                    --layout default \
                    --ansi \
                    --height 60% \
                    --prompt "${namespace}@${context} > " \
                    --bind 'ctrl-y:execute-silent(echo -n {+} | pbcopy)' \
                    --preview-window up,60%,follow,rounded \
                    --preview "kubecolor --force-colors --namespace {+} get ${resources:-pods,sts}" \
                    --header 'Press CTRL-Y to copy namespace name into clipboard'
         )

  if [[ -n "${newns}" ]]; then
    echo -e "\033[1;33m~~> ${newns}\033[0m"
    kubectl config set-context --current --namespace "${newns}"
    exitcode=$?
    kubecolor config get-contexts
    [[ 'true' = "${outputSt:-}" ]] &&
      echo -e "\n\033[1;33m~~> status:\033[0m" &&
      kubecolor -n "${newns}" get pods,sts,cm
  fi
  return ${exitcode:-0}
}

# kpo - kubectl show pods status and container logs in current namespace
# @inspired    : https://github.com/junegunn/fzf/blob/master/ADVANCED.md#log-tailing
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : using `fzf` to list all available pods in current namespace, and show pod and container logs
# @usage       : $ kst po,sts,cm
# [k]ubectl show provided resources [s][t]atus
# shellcheck disable=SC2016
function kpo() {
  : | command="kubectl get pods --namespace $(command kubectl config view --minify -o jsonpath='{..namespace}')" fzf \
    --info=inline --header-lines=1 \
    --layout default \
    --height 70% \
    --prompt "$(kubectl config view --minify -o jsonpath='{..namespace}')@$(kubectl config current-context | sed 's/-context$//')> " \
    --bind 'start:reload:$command' \
    --bind 'ctrl-r:reload:$command' \
    --preview-window up,70%,follow,rounded  \
    --preview 'kubecolor --force-colors logs --follow --all-containers --tail=500 {1}' "$@"
    # --header $'╱ CTRL-R (reload) ╱\n' \
}

# _can_i - kubectl check permission (auth can-i) for pods component
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : check whether given action is allowed in given namespaces; if namespace not provide, using default namespace
function _can_i() {
  local namespace
  namespace=$(command kubectl config view --minify -o jsonpath='{..namespace}')

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n | --namespace ) namespace="$2" ; shift 2 ;;
                     * ) break                    ;;
    esac
  done

  [[ 0 = "$#" ]] && echo -e "$(c Rs)>> ERROR: must provide action to check with$(c)\n\nUSAGE$(c Gis)\n\t\$ $0 list pod\n\t\$ $0 -n <namespace> create deploy$(c)" && return
  checker=$*
  r="$(kubectl auth can-i ${checker} -n ${namespace})";
  [[ 'yes' = "${r}" ]] && r="$(c Gs)${r}$(c)" || r="$(c Rs)${r}$(c)";
  echo -e "${r}";
}

# kcani - kubectl check permission (auth can-i)
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : check whether an action is allowed in given namespaces. support multiple selection
# [k]ubectl [can]-[i]
function kcani() {                         # [k]ubectl [can]-[i]
  local namespaces=''
  local actions='list get watch create update delete'
  local components='sts deploy secrets configmap ingressroute ingressroutetcp'

  namespaces=$( echo 'namespace_1 namespace_2 namespace_3 namespace_4' |
                      rg --color=always --colors match:fg:142 --passthru "${namespace}" |
                      fmt -1 |
                      fzf -1 -0 --no-sort --prompt='namespace> ' \
                          --bind 'ctrl-y:execute-silent(echo -n {+} | pbcopy)+abort' \
                          --header 'Press CTRL-Y to copy name into clipboard'
             )
  [[ -z "${namespaces}" ]] && echo "$(c Rs)ERROR: select at least one namespace !$(c)" && return

  while read -r namespace; do
    echo -e "\n>> $(c Ys)${namespace}$(c)"
    kpcani ${namespace}                  # for pods component

    for _c in ${components}; do
      local res=''
      echo -e ".. $(c Ms)${_c}$(c) :"
      for _a in ${actions}; do
        r=$(_can_i -n "${namespace}" "${_a}" "${_c}")
        res+="${r} ";
      done;                                # in actions
      echo -e "${actions}\n${res}" | "${COLUMN}" -t | sed 's/^/\t/g'
    done;                                  # in components

  done< <(echo "${namespaces}" | fmt -1)
}

# kpcani - kubectl check permission (auth can-i) for pods component
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description : check whether certain action is allowed in given namespaces
# [k]ubectl [p]od [can]-[i]
function kpcani() {                        # [k]ubectl [p]od [can]-[i]
  local components='pods'
  declare -A pactions
  pactions=(
             ['0_get']="get ${components}"
             ['1_get/exec']="get ${components}/exec"
             ['2_get/sub/exec']="get ${components} --subresource=exec"
             ['2_get/sub/log']="get ${components} --subresource=log"
             ['3_list']="list ${components}"
             ['4_create']="create ${components}"
             ['5_create/exec']="create ${components}/exec"
             ['6_get/sub/exec']="get ${components} --subresource=exec"
           )

  while read -r pnamespace; do
    local headers=''
    local pres=''
    while read -r _a; do
      headers+="$(sed -rn 's/^[0-9]+_(.+)$/\1/p' <<< ${_a}) "
      r=$(_can_i -n "${pnamespace}" "${pactions[${_a}]}")
      pres+="${r} "
    done < <( for _act in "${!pactions[@]}"; do echo "${_act}"; done | sort -h )
    echo -e ".. $(c Ms)pods$(c) :"
    echo -e "${headers}\n${pres}" | "${COLUMN}" -t | sed 's/^/\t/g'
  done< <(echo "$*" | fmt -1)
}

# /**************************************************************
#   __     __            _         _
#  / _|___/ _|  ___   __| |___  __| |_____ _ _
# |  _|_ /  _| |___| / _` / _ \/ _| / / -_) '_|
# |_| /__|_|         \__,_\___/\__|_\_\___|_|
#
# **************************************************************/

# drclr - docker remote clean images via keywords in tags
# @author      : marslo
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# [d]ocker [r]emote [c][l]ea[r]
function drclr() {                        # [d]ocker [r]emote [c][l]ea[r]
  local username='devops'
  local hostname='artifactory.sample.com'
  local registry='storage-ff-devops-docker'
  local delete=false
  local dangling=false
  local show=true
  local name=''
  local tag=''
  local cmd=''
  local usage
  usage="$(c Cs)drclr$(c) - $(c Cis)d$(c)ocker $(c Cis)r$(c)emote $(c Cis)c$(c)$(c Cis)l$(c)ea$(c Cs)r$(c)
  \nSYNOPSIS:
  \n\t$(c Gs)\$ drclr [ -h  | --help     ]
                [ -c  | --show     ]
                [ -d  | --delete   ]
                [ -dl | --dangling ]
                [ -t  | --tag      ]
                [ -n  | --name     ]
                [ -r  | --registry ]$(c)
  \nEXAMPLE:
  \n\tshow docker images with pattern of \`HOSTNAME/docker-local/marslo/*\` with tag of \`v1.0.0\`:
  \t\t$(c Ys)$ drclr -t 'v1.0.0' -r 'docker-local' -n 'marslo/*'$(c)
  \n\tdelete docker images with pattern of \`HOSTNAME/docker-local/marslo/*\` with tag of \`v1.0.0\`:
  \t\t$(c Ys)$ drclr -t 'v1.0.0' -r 'docker-local' -n 'marslo/*' -d$(c)
  "

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c  | --show     ) show=true     ; shift 1    ;;
      -dl | --dangling ) dangling=true ; shift 1    ;;
      -d  | --delete   ) delete=true   ; shift 1    ;;
      -t  | --tag      ) tag="$2"      ; shift 2    ;;
      -n  | --name     ) name="$2"     ; shift 2    ;;
      -r  | --registry ) registry="$2" ; shift 2    ;;
      -h  | --help     ) echo -e "${usage}"; return ;;
      *                ) break                      ;;
    esac
  done

  if [[ 'true' = "${dangling}" ]]; then
    name='--filter dangling=true'
    extraFormat='{{.Repository}}\\t'
    extraCmd=''
  else
    [[ -z "${tag}"  ]] && echo -e "$(c Rs)ERROR$(c): \`tag\` cannot be empty. check more options via \`-h\` or \`--help\`. EXIT ..." && return;
    [[ -n "${name}" ]] && name="${hostname}/${registry}/${name}"
    [[ 'true' = "${show}" ]] && extraCmd=" | column -t | grep --fixed-string ${tag}" || extraCmd=''
    extraFormat=''
  fi

  cmd="docker images ${name} --format \\\"${extraFormat}{{.Tag}}\\t{{.ID}}\\\" ${extraCmd}"
  [[ 'true' = "${delete}" ]] && cmd+=" | awk '{print \\\$NF}' | uniq | xargs -r docker rmi -f"

  hostnames=$(echo dc5-ssdfw{1,4,6,8,9,15,17,18,19,-vm1} |
              fmt -1 |
              fzf --cycle --exit-0 --prompt "hostname > " \
             )

  if [[ -n ${hostnames} ]]; then
    while read -r _hostname; do
      echo -e "$(c Wd)>>$(c) $(c Gis)${_hostname}$(c) $(c Wd)<<$(c)"
      eval "ssh -n ${username}@${_hostname} \"${cmd}\""
      eval "ssh -n ${username}@${_hostname} \"docker images --filter dangling=true -q | xargs -r docker rmi -f\""
    done <<< "${hostnames}"
  fi
}

# /**************************************************************
#   __     __                   _   _
#  / _|___/ _|  ___   _ __ _  _| |_| |_  ___ _ _
# |  _|_ /  _| |___| | '_ \ || |  _| ' \/ _ \ ' \
# |_| /__|_|         | .__/\_, |\__|_||_\___/_||_|
#                    |_|   |__/
# **************************************************************/

# activate venv - using `fzf` to list and activate python venv
# @author      : marslo
# @inspired    : https://seb.jambor.dev/posts/improving-shell-workflows-with-fzf/#virtual-env
# @source      : https://github.com/marslo/dotfiles/blob/main/.marslo/bin/ffunc.sh
# @description :
#   - -c | --create : create a new venv with given name
#   - -d | --delete : delete a venv from fzf list
# @usage       : $ avenv [ -d | --delete ]
#                        [ -c | --create <name> ]
# shellcheck disable=SC2155
function avenv() {
  local _venv=''
  local _del='false'

  function activeVenv() {
    [[ -n "$1" ]] &&
      source "$HOME/.venv/$1/bin/activate" &&
      echo -e "$(c Wd)>>$(c) $(c Wdi)venv$(c) $(c Gis)$1$(c) $(c Wdi)has been activated ..$(c)"
  }

  function deleteVenv() {
    # read -r -p "Do you want to delete venv $1 ( Y/N ) ? " answer
    printf "$(c Wi)Do you want to delete venv$(c) $(c Ms)%s$(c) $(c Wi)( Y/N ) ?$(c) " "$1"
    read -r answer
    if [[ "${answer}" != "${answer#[Yy]}" ]]; then
      [[ -n "${VIRTUAL_ENV}" ]] && [[ "$1" = "${VIRTUAL_ENV##*/}" ]] &&
      deactivate &&
      echo -e "$(c Wd)>>$(c) $(c Wdi)venv$(c) $(c Mis)$1$(c) $(c Wdi)has been deactivated ..$(c)"
      command rm -rf "$HOME/.venv/$1" &&
      echo -e "$(c Wd)>>$(c) $(c Wdi)venv$(c) $(c Mis)$1$(c) $(c Wdi)has been deleted ..$(c)"
    fi
  }

  function createVenv() {
    _newvenv="$1"
    if command ls --color=never "$HOME/.venv" | grep -qE "^${_newvenv}$"; then
      echo -e "$(c Ys)WARNING:$(c) $(c Gis)${_newvenv}$(c) $(c Wdi)already exists. activating ..$(c)"
    else
      python3 -m venv ~/.venv/${_newvenv}
      echo -e "$(c Wd)>>$(c) $(c Gis)${_newvenv}$(c) $(c Wdi)has been created. activating ..$(c)"
    fi
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c | --create ) _venv="$2"  ; shift 2 ;;
      -d | --delete ) _del="true" ; shift   ;;
                  * ) break                 ;;
    esac
  done

  if [[ "${_del}" = 'true' ]]; then
    _venv=$(command ls --color=never "$HOME/.venv" | fzf)
    [[ -n "${_venv}" ]] && deleteVenv "${_venv}"
  elif [[ -n "${_venv}" ]]; then
    createVenv "${_venv}"
    activeVenv "${_venv}"
    echo -e "$(c Wd)>>$(c) $(c Wid)install pip package$(c) $(c Cis)pynvim$(c) $(c Wdi)for nvim ..$(c)"
    python3 -m pip install --upgrade pynvim
  else
    _venv=$(command ls --color=never "$HOME/.venv" | fzf)
    activeVenv "${_venv}"
  fi
}

# /**************************************************************
#  _
# | |          _
# | | _   ____| |_
# | || \ / _  |  _)
# | |_) | ( | | |__
# |____/ \_||_|\___)
#
# **************************************************************/

# bat
function help() { "$@" --help 2>&1 | bat --plain --language=help ; }

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=marker:foldmarker=#\ **************************************************************/,#\ /**************************************************************
