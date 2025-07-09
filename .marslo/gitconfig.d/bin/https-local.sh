#!/usr/bin/env bash

set -euo pipefail

git config --local --unset-all url."https://github.com/".insteadOf
git config --local --add url."https://github.com/".insteadOf https://github.com/
git config --local --add url."https://github.com/".insteadOf git@ssh.github.com:
git config --local --add url."https://github.com/".insteadOf git@github.com:

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
