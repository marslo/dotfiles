#!/usr/bin/env bash
# shellcheck disable=SC2155
#=============================================================================
#     FileName : bash-ui.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-04-04 18:35:37
#   LastChange : 2025-04-04 21:57:15
#=============================================================================

# -------------------------------------------------------------------------- #
#                     bash-ui.sh — Bash CLI UI Utilities                     #
# -------------------------------------------------------------------------- #
# USAGE:                                                                     #
# $ source ./cli/bash-ui.sh                                                  #
#                                                                            #
# # print table                                                              #
# headers=("TITLE" "INFO")                                                   #
# rows=(                                                                     #
#   "Item 1|\033[32mSuccess\033[0m"                                          #
#   "Item 2|In progress"                                                     #
#   "Long title|⚠️ Warning"                                                  #
# )                                                                          #
# aligns=("center" "left")                                                   #
# print_table headers rows aligns                                            #
#                                                                            #
# # info line                                                                #
# infoLine "\033[33mTip:\033[0m All tasks complete!" "\033[33m=\033[0m" 80   #
# -------------------------------------------------------------------------- #

# ========= Utility Functions ==========
function _strip_ansi() { sed 's/\x1B\[[0-9;]*[mK]//g'; }
function _str_length() { echo -e "$1" | _strip_ansi | awk '{ print length }'; }
function repeat_char() { printf "%*s" "$2" '' | tr ' ' "$1"; }

# ========= Table Printer ==========

function print_table() {
  local -n _headers=$1
  local -n _rows=$2
  local -n _aligns=$3

  local cols=${#_headers[@]}
  local -a widths

  for ((i = 0; i < cols; i++)); do
    widths[i]=$(_str_length "${_headers[i]}")
  done

  for row in "${_rows[@]}"; do
    IFS='|' read -r -a fields <<<"$row"
    for ((i = 0; i < cols; i++)); do
      len=$(_str_length "${fields[i]}")
      ((len > widths[i])) && widths[i]=$len
    done
  done

  _print_line() {
    for ((i = 0; i < cols; i++)); do
      printf "+-%s-" "$(repeat_char '-' "${widths[i]}")"
    done
    echo "+"
  }

  _print_row() {
    local -a fields=("$@")
    for ((i = 0; i < cols; i++)); do
      local raw="${fields[i]}"
      local pad=${widths[i]}
      local clean=$(_str_length "$raw")
      case "${_aligns[i]}" in
        right  ) local space=$((pad - clean))
                 printf "| %*s%b " "$space" "" "$raw"
                 ;;
        center ) local left=$(( (pad - clean) / 2 ))
                 local right=$(( pad - clean - left ))
                 printf "| %*s%b%*s " "$left" "" "$raw" "$right" ""
                 ;;
        *      ) printf "| %b%*s " "$raw" $((pad - clean)) "" ;;
      esac
    done
    echo "|"
  }

  _print_line
  _print_row "${_headers[@]}"
  _print_line
  for row in "${_rows[@]}"; do
    IFS='|' read -r -a fields <<<"$row"
    _print_row "${fields[@]}"
  done
  _print_line
}

# ========= centered info line ==========
#
# USAGE:
#   infoLine "\033[32;3mSuccess\033[0m"
#   infoLine "\033[33mTip:\033[0m All tasks complete!" "\033[36;3m=\033[0m" 80
#
function infoLine() {
  local line="$1"
  local sep="${2:-\033[1;37m-\033[0m}"
  local width="${3:-${COLUMNS:-80}}"
  local cSep="$(echo -e "${sep}" | _strip_ansi)"
  local length="$(echo -e "${line}" | _strip_ansi | awk '{ print length }')"
  local dashes="$(printf '%*b' "$(( (width - length - 2) / 2 ))" '' | tr ' ' "${cSep}")"
  local cDashes="${sep//${cSep}/${dashes}}"

  printf "\n%b %b %b\n" "${cDashes}" "${line}" "${cDashes}"
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
