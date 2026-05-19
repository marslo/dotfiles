#!/usr/bin/env bash
# =============================================================================
#      FileName : update.sh
#        Author : marslo
#       Created : 2026-05-15 21:26:52
#    LastChange : 2026-05-18 17:02:24
# =============================================================================

set -euo pipefail

declare BIN_DIR="$HOME"/.marslo/bin
declare CONFIG_DIR="$HOME"/.marslo/.config

command curl -fsSL -o "${CONFIG_DIR}"/css-color-names.json https://github.com/bahamas10/css-color-names/raw/master/css-color-names.json
command curl -fsSL -o "${BIN_DIR}"/ansi                    https://git.io/ansi
command curl -fsSL -o "${BIN_DIR}"/batchip                 https://github.com/marslo/batchip/raw/main/batchip

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
