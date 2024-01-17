#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# if [ -f $(brew --prefix)/etc/bash_completion ]; then
  # source $(brew --prefix)/etc/bash_completion;
# fi

# [ -f /Users/marslo/.marslo/.marslorc ] && source /Users/marslo/.marslo/.marslorc

# https://brettterpstra.com/2014/07/12/making-cd-in-bash-a-little-better/
# export FIGNORE="Application Scripts:Applications (Parallels):ScrivWatcher:ScriptingAdditions"
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# for :terminal in nvim
source "$(brew --prefix git)"/etc/bash_completion.d/git-*.sh

# set -a; source "/Users/marslo/.marslo/.marslorc"; set +a;         # `-a`: mark variables which are modified or created for export
# set -x; source "/Users/marslo/.marslo/.marslorc"; set +x;         # `-x`: print commands and their arguments as they are executed
# bash -ixlc : 2>&1 | grep ...                                      # debug bash full start process : https://unix.stackexchange.com/a/322468/29178
test -f "$HOME/.marslo/.marslorc" && source "$HOME/.marslo/.marslorc"

# shellcheck disable=SC2155
export PATH=$( echo "$PATH" | tr ':' '\n' | uniq | sed '/^$/d' | paste -s -d: )
test -d "$HOME"/perl5 && eval "$(perl -I"$HOME"/perl5/lib/perl5 -Mlocal::lib="$HOME"/perl5)"

# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
