#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC1090

# set -a; source "/Users/marslo/.marslo/.marslorc"; set +a;         # `-a`: mark variables which are modified or created for export
# set -x; source "/Users/marslo/.marslo/.marslorc"; set +x;         # `-x`: print commands and their arguments as they are executed
# bash -ixlc : 2>&1 | grep ...                                      # debug bash full start process : https://unix.stackexchange.com/a/322468/29178
! test -f "$HOME/.marslo/.marslorc" || source "$HOME/.marslo/.marslorc"

# remove empty line:
# - sed '/^$/d'
# - awk 'NF > 0' or awk 'NF'
# remove duplicate line:
# - awk '!x[$0]++'
# - https://stackoverflow.com/a/11532197/2940319
# shellcheck disable=SC2155
if [[ '1' = $(isOSX) ]]; then
  test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
  export PATH=$( echo "$PATH" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | /usr/local/opt/coreutils/libexec/gnubin/paste -s -d: )
else
  export PATH=$( echo "$PATH" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | paste -s -d: )
fi
! test -d "$HOME"/perl5 || eval "$(perl -I"$HOME"/perl5/lib/perl5 -Mlocal::lib="$HOME"/perl5)"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
