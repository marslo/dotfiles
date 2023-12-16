#!/usr/bin/env bash
# shellcheck disable=SC1091

# bash -ixlc : 2>&1 | grep ...                                      # debug bash full start process : https://unix.stackexchange.com/a/322468/29178
test -f "${HOME}/.marslo/.marslorc" && source "${HOME}/.marslo/.marslorc"

# shellcheck disable=SC2155
export PATH=$( echo "$PATH" | tr ':' '\n' | uniq | paste -s -d:  )
test -d "$HOME"/perl5 && eval "$(perl -I"$HOME"/perl5/lib/perl5 -Mlocal::lib="$HOME"/perl5)"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
