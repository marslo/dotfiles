#!/usr/bin/env bash
# shellcheck disable=SC2155
#=============================================================================
#     FileName : print-table.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2025-04-04 18:35:37
#   LastChange : 2025-04-04 21:57:24
#=============================================================================

# -------------------------------------------------------------------------- #
#                  print-table.sh — CLI table printing tool                  #
#                 supports column alignment and color output                 #
# -------------------------------------------------------------------------- #
# USAGE:                                                                     #
# $ source ./cli/bash-ui.sh                                                  #
#                                                                            #
# headers=("TITLE" "INFO")                                                   #
# rows=(                                                                     #
#   "Item 1|\033[32mSuccess\033[0m"                                          #
#   "Item 2|In progress"                                                     #
#   "Long title|⚠️ Warning"                                                  #
# )                                                                          #
# aligns=("center" "left")                                                   #
# print_table headers rows aligns                                            #
# -------------------------------------------------------------------------- #

function _strip_ansi() { sed 's/\x1B\[[0-9;]*[mK]//g'; }
function _str_length() { echo -e "$1" | _strip_ansi | awk '{ print length }'; }
function repeat_char() { printf "%*s" "$2" '' | tr ' ' "$1"; }

function print_table() {
  local -n _headers=$1
  local -n _rows=$2
  local -n _aligns=$3

  local cols=${#_headers[@]}
  local -a widths

  # 计算每列最大宽度
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

  # print line: note that the space is added, 1 on each side, so add 2
  _print_line() {
    for ((i = 0; i < cols; i++)); do
      printf "+-%s-" "$(repeat_char '-' "${widths[i]}")"
    done
    echo "+"
  }

  # print row
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

  # 输出表格
  _print_line
  _print_row "${_headers[@]}"
  _print_line
  for row in "${_rows[@]}"; do
    IFS='|' read -r -a fields <<<"$row"
    _print_row "${fields[@]}"
  done
  _print_line
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
