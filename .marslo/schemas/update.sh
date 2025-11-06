#!/usr/bin/env bash
#=============================================================================
#     FileName : update.sh
#       Author : marslo
#      Created : 2025-11-06 09:17:15
#   LastChange : 2025-11-06 10:38:04
#=============================================================================

set -euo pipefail

# shellcheck disable=SC2155
declare SCHEMA_DIR="$(realpath "$(dirname "$0")")"
declare -r SCHEMA_URL='https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json'
declare -a FILES=(
  'pre-commit-config.json'
  'github-workflow.json'
  'yamllint.json'
  'pre-commit-hooks.json'
)

function info() { echo -e "\033[30;48;5;151m>> $*\033[0m"; }
function note() { echo -e "\033[3;7;37m>> $*\033[0m"; }
function warn() { echo -e "\033[30;48;5;174m>> $*\033[0m"; }

for file in "${FILES[@]}"; do
  curl -fsSL --create-dirs -o "${SCHEMA_DIR}/${file}" "${SCHEMA_URL}/${file}"
  # shellcheck disable=SC2015
  test ! -s "${SCHEMA_DIR}/${file}" && { warn "failed to download or empty file: ${file}" >&2; exit 1; } \
                                    || { note "${file} downloaded"; }

  # using local pre-commit-hooks.json schema in pre-commit-config.json
  if [[ 'pre-commit-config.json' = "${file}" ]]; then
    LOCAL_HOOK_FILEPATH="file://${SCHEMA_DIR}/pre-commit-hooks.json"
    sed "s#https://json.schemastore.org/pre-commit-hooks.json#${LOCAL_HOOK_FILEPATH}#g" -i "${SCHEMA_DIR}/${file}"
  fi
done

declare -a json=()
for file in "${FILES[@]}"; do
  [[ "${file}" == *hooks.json   ]] && continue
  [[ -f "${SCHEMA_DIR}/${file}" ]] || continue
  json+=("  \"file://${SCHEMA_DIR}/${file}\": \".${file}\"")
done

info 'use the following in coc-settings.json:'
echo '"yaml.schemas": {'
for i in "${!json[@]}"; do
  printf "%s" "${json[$i]}"
  [[ $i -lt $((${#json[@]} - 1)) ]] && echo ',' || echo
done
echo "}"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
