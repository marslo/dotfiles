#!/usr/bin/env bash
# shellcheck disable=SC1091

[[ -f /etc/bash_completion ]] && . /etc/bash_completion

# for :terminal in nvim
if [[ 'Darwin' = $(uname) ]]; then
  source "$(brew --prefix git)"/etc/bash_completion.d/git-*.sh
fi
function bello() { source ~/.bash_profile; }

# https://brettterpstra.com/2014/07/12/making-cd-in-bash-a-little-better/
# export FIGNORE="Application Scripts:Applications (Parallels):ScrivWatcher:ScriptingAdditions"
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
