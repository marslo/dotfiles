#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# if [ -f $(brew --prefix)/etc/bash_completion ]; then
  # source $(brew --prefix)/etc/bash_completion;
# fi

# https://brettterpstra.com/2014/07/12/making-cd-in-bash-a-little-better/
# export FIGNORE="Application Scripts:Applications (Parallels):ScrivWatcher:ScriptingAdditions"
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# for :terminal in nvim
if [[ '1' = $(isOSX) ]]; then
  source "$(brew --prefix git)"/etc/bash_completion.d/git-*.sh
fi

# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
