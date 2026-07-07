#!/usr/bin/env bash
# shellcheck disable=SC2086,SC2155
# =============================================================================
#     FileName : fzf-preview.sh
#       Author : marslo
#      Created : 2026-05-11 22:50:00
#   LastChange : 2026-07-06 22:49:42
#  Description : unified fzf preview command for files and directories
#                used by: FZF_CTRL_T_OPTS (env.d/fzf), _load_fzf_context() (ffunc.sh)
#       Syntax : fzf-preview.sh FILENAME[:LINENO][:IGNORED]
# =============================================================================
# environment variables:
#   - FZF_TOILET=true/false        : whether use `toilet` to preview binary file info
#   - FZF_TOILET_FONT=<font_name>  : the font name for `toilet` preview, default to `bfraktur`
# example:
#     export FZF_TOILET=true
#     export FZF_TOILET_FONT=bfraktur

# clear tty
printf "\e[0m"
printf "\e_Ga=d\e\\" > /dev/tty

if [[ $# -ne 1 ]]; then
  >&2 echo "usage: $0 FILENAME[:LINENO][:IGNORED]"
  exit 1
fi

# ~/path expansion
file=${1/#\~\//${HOME}/}
[[ -z "${file}" ]] && exit 0

# file:lineno[:col] parsing (for grep/rg results)
center=0
if [[ ! -r "${file}" ]]; then
  if [[ ${file} =~ ^(.+):([0-9]+)\ *$ ]] && [[ -r "${BASH_REMATCH[1]}" ]]; then
    file="${BASH_REMATCH[1]}"
    center="${BASH_REMATCH[2]}"
  elif [[ ${file} =~ ^(.+):([0-9]+):[0-9]+\ *$ ]] && [[ -r "${BASH_REMATCH[1]}" ]]; then
    file="${BASH_REMATCH[1]}"
    center="${BASH_REMATCH[2]}"
  fi
fi

# MIME type for fallback detection. i.e.:
# $ file --brief --dereference --mime -- <name>.png
# image/png; charset=binary
declare mime
mime="$(file --brief --dereference --mime -- "${file}" 2>/dev/null)"

# =========================================================================== #
# document preview: prefer `batchip` > `bat` > `cat`                         #
# =========================================================================== #
declare -a CAT=( "$(type -P cat)" )
# batchip (~/.marslo/bin/batchip) > batcat (/usr/bin/batcat - Debian/Ubuntu) > bat (/usr/local/bin/bat - macOS)
declare _BAT_CMD=$(type -P batchip || type -P batcat || type -P bat)
if [[ -n "${_BAT_CMD}" ]]; then
  CAT=( "${_BAT_CMD}" --style="${BAT_STYLE:-numbers}" --theme='Nord' --color=always --pager=never --line-range :500 )
  [[ "${center}" -gt 0 ]] && CAT+=( --highlight-line="${center}" )
fi

# =========================================================================== #
# directories preview, prefer `eza` > `tree` > `ls`                           #
# =========================================================================== #
declare -a TREE=( command ls '-Al' )
if type -P eza >/dev/null; then
  TREE=( command eza --tree -L 3 --classify --ignore-glob=".git|node_modules|.DS_Store|__pycache__|.venv" --color always --icons )
elif type -P tree >/dev/null; then
  TREE=( command tree '-C' '-L' 2 )
fi

# =========================================================================== #
# binary file info preview, prefer `toilet` [+ `lolcat`] > `file`             #
# =========================================================================== #
declare GLOW_PATH="$(type -P glow)"
declare TOILET_PATH="$(type -P toilet)"
declare LOLCAT_PATH="$(type -P lolcat)"
declare CHAFA_PATH="$(type -P chafa)"
declare -a CHAFA_CMD=( "${CHAFA_PATH}" --center on )
# test "$(uname -s)" = "Darwin" && CHAFA_CMD+=( --format iterm )

# toilet + lolcat to show `$(file -bL FILE)`
function _show_binary() {
  local _file="${1:?file is required}"
  local _info
  _info="$(file -bL "${_file}")"
  ${FZF_TOILET:-true} && [[ -x "${TOILET_PATH}" ]] && _info=$(printf '%s\n' "${_info}" | "${TOILET_PATH}" -f "${FZF_TOILET_FONT:-bfraktur}" -w "${FZF_PREVIEW_COLUMNS:-65}")
  [[ -x "${LOLCAT_PATH}" ]] && printf '%s\n' "${_info}" | "${LOLCAT_PATH}" -f || printf '%s\n' "${_info}"
}

# =========================================================================== #
# image preview: Kitty icat > chafa > imgcat > binary info fallback           #
# =========================================================================== #
function _show_image() {
  local _file="${1:?file is required}"

  local dim="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
  if [[ "${dim}" == 'x' ]]; then
    dim=$(stty size < /dev/tty | awk '{print $2 "x" $1}')
  elif ! [[ ${KITTY_WINDOW_ID} ]] && (( FZF_PREVIEW_TOP + FZF_PREVIEW_LINES == $(stty size < /dev/tty | awk '{print $1}') )); then
    dim="${FZF_PREVIEW_COLUMNS}x$(( FZF_PREVIEW_LINES - 1 ))"
  fi

  # kitty icat
  if { [[ ${KITTY_WINDOW_ID} ]] || [[ ${GHOSTTY_RESOURCES_DIR} ]]; } && type -P kitten >/dev/null; then
    kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="${dim}@0x0" "${_file}" | sed '$d' | sed $'$s/$/\e[m/'

  # chafa (terminal image to ANSI/Unicode)
  elif [[ -x "${CHAFA_PATH}" ]]; then
    # sips (macOS)
    if type -P sips >/dev/null; then
      read -r pw ph < <(sips -g pixelWidth -g pixelHeight "${_file}" 2>/dev/null | awk '/pixel/ {printf "%d ", $2}')
    # identify (ImageMagick)
    elif type -P identify >/dev/null; then
      read -r pw ph < <(identify -format '%w %h' "${_file}" 2>/dev/null)
    fi
    maxpw=$(( FZF_PREVIEW_COLUMNS * 12 ))
    maxph=$(( FZF_PREVIEW_LINES   * 24 ))
    if [[ "${_file,,}" == *.svg ]] || [[ -z "${pw}" ]] || [[ "${pw}" -gt "${maxpw}" ]] || [[ "${ph}" -gt "${maxph}" ]]; then
      "${CHAFA_CMD[@]}" --size "${dim}" "${_file}"
    else
      "${CHAFA_CMD[@]}" "${_file}"
    fi

  # imgcat (iTerm2)
  elif type -P imgcat >/dev/null; then
    imgcat -W "${FZF_PREVIEW_COLUMNS}" -H "${FZF_PREVIEW_LINES}" "${_file}"
  else
    _show_binary "${_file}"
  fi
}

# =========================================================================== #
# html preview: w3m > html2text > cat (with file name)                        #
# =========================================================================== #
function _show_html() {
  local _file="${1:?file is required}"
  local _lang='txt'
  local _suffix=' (Rendered)'
  local -a _html_preview=()

  if type -P w3m >/dev/null; then
    _html_preview=( w3m -dump "${_file}" )
  elif type -P html2text >/dev/null; then
    _html_preview=( html2text -style pretty "${_file}" )
  else
    _lang='html'
    _suffix=''
    _html_preview=( cat -- "${_file}" )
  fi

  "${CAT[@]}" ${_BAT_CMD:+--language="${_lang}" --style=full --file-name="${_file}${_suffix}"} < <("${_html_preview[@]}")
}

# =========================================================================== #
# markdown preview: glow > cat (with file name)                               #
# =========================================================================== #
function _show_md() {
  local _file="${1:?file is required}"

  if [[ -x "${GLOW_PATH}" ]]; then
    CLICOLOR_FORCE=1 "${GLOW_PATH}" -s dark -w "${FZF_PREVIEW_COLUMNS:-65}" -- "${_file}"
  else
    "${CAT[@]}" -- "${_file}"
  fi
}

# =========================================================================== #
# pdf preview: pdftotext (1-5 pages, brew install poppler) > binary info      #
# =========================================================================== #
function _show_pdf() {
  local _file="${1:?file is required}"

  if type -P pdftotext >/dev/null; then
    local -a _pdf_preview=( command pdftotext -f 1 -l 5 -nopgbrk -q "${_file}" - )
    "${CAT[@]}" ${_BAT_CMD:+--language=txt --style=full --file-name="${_file} (Text Mode)"} < <("${_pdf_preview[@]}")
  else
    _show_binary "${_file}"
  fi
}

# =========================================================================== #
# vim/nvim modeline filetype -> bat language token                            #
# (names often differ, e.g. vim `sshconfig` -> bat `SSH Config` / ssh_config) #
# add new mappings here when a vim ft doesn't match a bat syntax name         #
# =========================================================================== #
declare -A FT_TO_BAT=(
  [sshconfig]=ssh_config
  [config]=ssh_config
  [sshdconfig]=sshd_config
  [dosini]=ini
  [conf]=ini
  [zsh]=bash
  [csh]=bash
  [cmake]=cmake
  [dockerfile]=Dockerfile
)

# echo the bat language token derived from a file's vim/nvim modeline (empty when none found)
function _render_ft() {
  local _file="${1:?file is required}"
  local _ft
  _ft=$(grep -Eo --color=never '(filetype|ft)=[a-zA-Z0-9_-]+' "${_file}" 2>/dev/null | awk -F= 'END{print $2}')
  [[ -z "${_ft}" ]] && return 0
  printf '%s' "${FT_TO_BAT[${_ft,,}]:-${_ft}}"
}

# main
case "${file}" in
  *.html | *.HTM ) _show_html "${file}" ;;
  *.md   | *.MD  ) _show_md   "${file}" ;;
  *.pdf  | *.PDF ) _show_pdf  "${file}" ;;
  *              ) if [[ -d "${file}" ]]; then
                     "${TREE[@]}" "${file}"
                   elif [[ ${mime} =~ image/ ]]; then
                     _show_image "${file}"
                   elif file -bL --mime-encoding "${file}" | grep -iq "binary" && ! iconv -f utf-8 -t utf-8 "${file}" >/dev/null 2>&1; then
                     _show_binary "${file}"
                   else
                     # extension ? bat auto-detects (fast) > vim modeline (ft) > bat auto-detect
                     declare -a _lang=()
                     if [[ "${file##*/}" != *.* ]]; then
                       declare lang
                       lang="$(_render_ft "${file}")"
                       [[ -n "${lang}" ]] && _lang=( --language="${lang}" )
                     fi
                     # fall back to bat auto-detect when the language is not a syntax bat knows (e.g. `config`)
                     "${CAT[@]}" "${_lang[@]}" -- "${file}" 2>/dev/null || "${CAT[@]}" -- "${file}"
                   fi
                   ;;
esac

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
