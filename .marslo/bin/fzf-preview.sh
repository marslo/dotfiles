#!/usr/bin/env bash
# shellcheck disable=SC2086,SC2155
# =============================================================================
#     FileName : fzf-preview.sh
#       Author : marslo
#      Created : 2026-05-11 22:50:00
#   LastChange : 2026-05-15 20:06:56
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

# MIME type for fallback detection
# i.e.: $ file --brief --dereference --mime -- <name>.png
# image/png; charset=binary
declare mime
mime="$(file --brief --dereference --mime -- "${file}" 2>/dev/null)"

# tool detection
declare -a CAT=( "$(type -P cat)" )
# batcat - Debian/Ubuntu
if type -P batcat >/dev/null; then
  CAT=( "$(type -P batcat)" --style="${BAT_STYLE:-numbers}" --theme='Nord' --color=always --pager=never --line-range :500 )
# bat - macOS
elif type -P batcolor >/dev/null; then
  CAT=( "$(type -P batcolor)" --style="${BAT_STYLE:-numbers}" --theme='Nord' --color=always --pager=never --line-range :500 )
elif type -P bat >/dev/null; then
  CAT=( "$(type -P bat)" --style="${BAT_STYLE:-numbers}" --theme='Nord' --color=always --pager=never --line-range :500 )
fi
[[ "${center}" -gt 0 ]] && CAT+=( --highlight-line="${center}" )

declare -a TREE=( command ls '-Al' )
type -P tree >/dev/null && TREE=( command tree '-C' '-L' 2 )

declare GLOW_PATH="$(type -P glow)"
declare TOILET_PATH="$(type -P toilet)"
declare LOLCAT_PATH="$(type -P lolcat)"
declare CHAFA_PATH="$(type -P chafa)"
declare -a CHAFA_CMD=( "${CHAFA_PATH}" --center on )
test "$(uname -s)" = "Darwin" && CHAFA_CMD+=( --format iterm )

# toilet + lolcat to show `$(file -bL FILE)`
function _show_binary_info() {
  local _file="${1:?file is required}"
  local _info
  _info="$(file -bL "${_file}")"
  ${FZF_TOILET:-true} && [[ -x "${TOILET_PATH}" ]] && _info=$(printf '%s\n' "${_info}" | "${TOILET_PATH}" -f "${FZF_TOILET_FONT:-bfraktur}" -w "${FZF_PREVIEW_COLUMNS:-65}")
  [[ -x "${LOLCAT_PATH}" ]] && printf '%s\n' "${_info}" | "${LOLCAT_PATH}" -f || printf '%s\n' "${_info}"
}

# image preview: Kitty icat > chafa > imgcat > binary info fallback
function _show_image() {
  local _file="${1:?file is required}"

  local dim="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
  if [[ "${dim}" == 'x' ]]; then
    dim=$(stty size < /dev/tty | awk '{print $2 "x" $1}')
  elif ! [[ ${KITTY_WINDOW_ID} ]] && (( FZF_PREVIEW_TOP + FZF_PREVIEW_LINES == $(stty size < /dev/tty | awk '{print $1}') )); then
    dim="${FZF_PREVIEW_COLUMNS}x$(( FZF_PREVIEW_LINES - 1 ))"
  fi

  if { [[ ${KITTY_WINDOW_ID} ]] || [[ ${GHOSTTY_RESOURCES_DIR} ]]; } && type -P kitten >/dev/null; then
    kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="${dim}@0x0" "${_file}" | sed '$d' | sed $'$s/$/\e[m/'
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
    echo
  elif type -P imgcat >/dev/null; then
    imgcat -W "${FZF_PREVIEW_COLUMNS}" -H "${FZF_PREVIEW_LINES}" "${_file}"
  else
    _show_binary_info "${_file}"
  fi
}

# main
case "${file}" in
  *.md | *.MD ) if [[ -x "${GLOW_PATH}" ]]; then
                  CLICOLOR_FORCE=1 "${GLOW_PATH}" -s dark -w "${FZF_PREVIEW_COLUMNS:-65}" -- "${file}"
                else
                  "${CAT[@]}" -- "${file}"
                fi
                ;;
  *           ) if [[ -d "${file}" ]]; then
                  "${TREE[@]}" "${file}"
                elif [[ ${mime} =~ image/ ]]; then
                  _show_image "${file}"
                elif file -bL --mime-encoding "${file}" | grep -iq "binary" && ! iconv -f utf-8 -t utf-8 "${file}" >/dev/null 2>&1; then
                  _show_binary_info "${file}"
                else
                  # 1. has extension → bat auto-detects (fast)
                  # 2. no extension  → try vim modeline, fallback to bat auto-detect
                  if [[ "${file##*/}" != *.* ]]; then
                    declare ft
                    ft=$(grep -Eo '(filetype|ft)=[a-zA-Z0-9_-]+' "${file}" 2>/dev/null | awk -F= 'END{print $2}')
                    [[ -n "${ft}" ]] && CAT+=( --language="${ft}" )
                  fi
                  "${CAT[@]}" -- "${file}" 2>/dev/null || "${CAT[@]}" -- "${file}"
                fi
                ;;
esac
