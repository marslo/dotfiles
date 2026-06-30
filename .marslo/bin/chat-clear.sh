#!/usr/bin/env bash
# =============================================================================
#      FileName : chat-clear.sh
#        Author : marslo
#       Created : 2026-06-25 23:06:00
#    LastChange : 2026-06-25 23:24:51
# =============================================================================

# `cursor agent` chat sessions cleanup tool.
# Location: stored under ~/.cursor/chats; Layout:  ~/.cursor/chats/<workspace-hash>/<chat-id>/...

set -euo pipefail
shopt -s nullglob

# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}")"
declare -r CHATS_DIR="${HOME}/.cursor/chats"

# ── tiny color helpers (no external deps) ───────────────────────────────────
if [[ -t 1 ]]; then
  declare -r R=$'\033[0m' B=$'\033[1m' DIM=$'\033[2m'
  declare -r RED=$'\033[31m' GRN=$'\033[32m' YLW=$'\033[33m' CYN=$'\033[36m'
else
  declare -r R='' B='' DIM='' RED='' GRN='' YLW='' CYN=''
fi
info()  { echo -e "${CYN}::${R} $*"; }
ok()    { echo -e "${GRN}✓${R} $*"; }
warn()  { echo -e "${YLW}!${R} $*" >&2; }
error() { echo -e "${RED}✗ ERROR:${R} $*" >&2; }

declare DO_ALL=0 DO_BACKUP=0 ASSUME_YES=0
declare TARGET_ID=''

declare -r USAGE="${B}NAME${R}
  ${ME} - clean up local 'cursor agent' chat sessions (~/.cursor/chats)

${B}USAGE${R}
  ${YLW}\$ ${ME}${R} ${DIM}[OPTIONS]${R}

${B}OPTIONS${R}
  ${GRN}-a${R}, ${GRN}--all${R}            delete ALL chat-id sessions
  ${GRN}    --id${R} ${CYN}<chat-id>${R}   delete a single chat-id session
  ${GRN}-b${R}, ${GRN}--backup${R}         back up ~/.cursor/chats before deleting
                       (or back up only, when used without -a/--id)
  ${GRN}-l${R}, ${GRN}--list${R}           list existing chat-id sessions and exit
  ${GRN}-y${R}, ${GRN}--yes${R}            skip the confirmation prompt
  ${GRN}-h${R}, ${GRN}--help${R}           show this help and exit

${B}EXAMPLES${R}
  ${YLW}\$ ${ME} --list${R}
  ${YLW}\$ ${ME} --id bb5afbf3-f678-4b64-890d-7a88769041bc${R}
  ${YLW}\$ ${ME} --backup --all${R}
  ${YLW}\$ ${ME} -b${R}                 ${DIM}# backup only${R}
"

# ── helpers ─────────────────────────────────────────────────────────────────
function listChats() {
  local -a dirs=( "${CHATS_DIR}"/*/*/ )
  [[ ${#dirs[@]} -eq 0 ]] && { info "no chat sessions found in ${CHATS_DIR}"; return 0; }
  local d
  for d in "${dirs[@]}"; do
    printf '%s  %s  %s(ws:%s)%s\n' \
      "$(date -r "${d}" '+%Y-%m-%d %H:%M' 2>/dev/null || echo '????-??-?? ??:??')" \
      "$(basename "${d}")" \
      "${DIM}" "$(basename "$(dirname "${d}")")" "${R}"
  done | sort
  echo -e "${DIM}── total: ${#dirs[@]} session(s)${R}"
}

function backup() {
  [[ -d "${CHATS_DIR}" ]] || { warn "nothing to back up; ${CHATS_DIR} does not exist"; return 0; }
  local dest; dest="${CHATS_DIR}.bak.$(date '+%Y%m%d-%H%M%S')"
  info "backing up ${CHATS_DIR} -> ${dest} ..."
  cp -a "${CHATS_DIR}" "${dest}"
  ok "backup created: ${B}${dest}${R}"
}

function confirm() {
  local prompt="$1"
  [[ "${ASSUME_YES}" -eq 1 ]] && return 0
  local ans
  read -r -p "$(echo -e "${YLW}?${R} ${prompt} [y/N] ")" ans
  [[ "${ans}" =~ ^[Yy]$ ]]
}

# ── arg parsing ─────────────────────────────────────────────────────────────
[[ $# -eq 0 ]] && { echo -e "${USAGE}"; exit 0; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a | --all    ) DO_ALL=1            ; shift   ;;
    --id          ) TARGET_ID="${2:-}"  ; shift 2 ;;
    --id=*        ) TARGET_ID="${1#*=}" ; shift   ;;
    -b | --backup ) DO_BACKUP=1         ; shift   ;;
    -l | --list   ) listChats           ; exit 0  ;;
    -y | --yes    ) ASSUME_YES=1        ; shift   ;;
    -h | --help   ) echo -e "${USAGE}"  ; exit 0  ;;
    *             ) error "unknown option: '$1'"; echo -e "${USAGE}" >&2; exit 1 ;;
  esac
done

# ── validation ──────────────────────────────────────────────────────────────
[[ -d "${CHATS_DIR}" ]] || { error "chats directory not found: ${CHATS_DIR}"; exit 1; }

if [[ "${DO_ALL}" -eq 1 && -n "${TARGET_ID}" ]]; then
  error "--all and --id are mutually exclusive"; exit 1
fi

# backup-only mode (no deletion requested)
if [[ "${DO_ALL}" -eq 0 && -z "${TARGET_ID}" ]]; then
  [[ "${DO_BACKUP}" -eq 1 ]] && { backup; exit 0; }
  error "nothing to do: specify --all, --id <chat-id>, or --backup"; exit 1
fi

# ── run ─────────────────────────────────────────────────────────────────────
[[ "${DO_BACKUP}" -eq 1 ]] && backup

if [[ -n "${TARGET_ID}" ]]; then
  declare -a matches=( "${CHATS_DIR}"/*/"${TARGET_ID}"/ )
  if [[ ${#matches[@]} -eq 0 ]]; then
    error "chat-id not found: ${TARGET_ID}"; exit 1
  fi
  info "found ${B}${#matches[@]}${R} match(es) for ${CYN}${TARGET_ID}${R}:"
  printf '   %s\n' "${matches[@]}"
  if confirm "delete the above chat session(s)?"; then
    rm -rf -- "${matches[@]}"
    ok "deleted chat-id ${B}${TARGET_ID}${R}"
  else
    info "aborted; nothing deleted"
  fi

elif [[ "${DO_ALL}" -eq 1 ]]; then
  declare -a all=( "${CHATS_DIR}"/*/*/ )
  if [[ ${#all[@]} -eq 0 ]]; then
    info "no chat sessions to delete"; exit 0
  fi
  warn "this will delete ALL ${B}${#all[@]}${R} chat session(s) under ${CHATS_DIR}"
  if confirm "proceed?"; then
    # delete only the already-collected, validated paths (no re-globbing)
    rm -rf -- "${all[@]}"
    # prune now-empty workspace-hash dirs
    find "${CHATS_DIR}" -mindepth 1 -maxdepth 1 -type d -empty -delete 2>/dev/null || true
    ok "deleted all ${B}${#all[@]}${R} chat session(s)"
  else
    info "aborted; nothing deleted"
  fi
fi

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
