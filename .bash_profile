#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC1090

[[ -f /etc/bash_completion ]] && . /etc/bash_completion


# https://iterm2.com/documentation-scripting-fundamentals.html
# function iterm2_print_user_vars() { iterm2_set_user_var gitBranch $(git symbolic-ref --short HEAD); }
# export LC_ALL=en_US.UTF-8

# set -a; source "/Users/marslo/.marslo/.marslorc"; set +a;         # `-a`: mark variables which are modified or created for export
# set -x; source "/Users/marslo/.marslo/.marslorc"; set +x;         # `-x`: print commands and their arguments as they are executed
# bash -ixlc : 2>&1 | grep ...                                      # debug bash full start process : https://unix.stackexchange.com/a/322468/29178
test -f "$HOME/.marslo/.marslorc" && source "$HOME/.marslo/.marslorc"

# shellcheck disable=SC2155
export PATH=$( echo "$PATH" | tr ':' '\n' | uniq | sed '/^$/d' | paste -s -d: )
test -d "$HOME"/perl5                            && eval "$(perl -I"$HOME"/perl5/lib/perl5 -Mlocal::lib="$HOME"/perl5)"
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
