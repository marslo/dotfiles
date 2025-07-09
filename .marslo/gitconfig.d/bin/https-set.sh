#!/usr/bin/env bash

set -euo pipefail

# for git alias - https-set

git config --global --add url.https://github.com/.insteadOf git@github.com:
git config --global --add url.https://github.com/.insteadOf git@ssh.github.com:
git config --global --add url.https://github.com/.insteadOf git@github-marslo.com:
git config --global --add url.https://github.com/.insteadOf git@github-re.com:
git config --global --add url.https://github.com/.insteadOf git@github-mvl.com:
git config --global --add url.https://github.com/.insteadOf git@github-mrvl.com:

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
