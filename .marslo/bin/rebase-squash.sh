#!/usr/bin/env bash

C=$1
GIT_EDITOR="sed -i -e '2,$C s/^pick /s /'" git rebase -i HEAD~$C

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
