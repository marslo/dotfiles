#!/usr/bin/env bash

set -euo pipefail

jq '.' "$1" 2>/dev/null | sed 's/\\n/\n/g' || cat "$1"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
