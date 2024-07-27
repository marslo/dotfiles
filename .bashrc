#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC1091,SC2015,SC2155

# wsl
if uname -r | command grep -q -i 'microsoft'; then
  test -f ~/.marslo/.marslorc.wsl && source ~/.marslo/.marslorc.wsl
  test -f ~/.bash_profile         && source ~/.bash_profile
else
  test -f /etc/bash_completion    && source /etc/bash_completion
fi

# for :terminal in nvim, avoid scp issue from non-mac system
if [[ 'Darwin' = $(uname) ]]; then
  command -v brew >/dev/null && source "$(brew --prefix git)"/etc/bash_completion.d/git-*.sh \
                             || source "/usr/local/opt/git/etc/bash_completion.d/git-prompt.sh"
else
  test -f "/etc/bash_completion.d/git-prompt"         && source "/etc/bash_completion.d/git-prompt"
  test -f "/usr/local/libexec/git-core/git-prompt.sh" && source "/usr/local/libexec/git-core/git-prompt.sh"
fi

# remove empty line:
# - sed '/^$/d'
# - awk 'NF > 0' or awk 'NF'
# remove duplicate line:
# - awk '!x[$0]++'
# - https://stackoverflow.com/a/11532197/2940319
if [[ 'Darwin' = "$(uname)" ]]; then
  export PATH=$( echo "$PATH" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | /usr/local/opt/coreutils/libexec/gnubin/paste -s -d: )
else
  export PATH=$( echo "$PATH" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | paste -s -d: )
fi

# ubuntu/wsl
if [[ -f /etc/os-release ]] && [[ 'debian' = $(awk -F '=' '/ID_LIKE/ { print $2 }' /etc/os-release) ]]; then
  export DEBIAN_FRONTEND=noninteractive
fi

function bello() { source ~/.bash_profile; }

# https://brettterpstra.com/2014/07/12/making-cd-in-bash-a-little-better/
# export FIGNORE="Application Scripts:Applications (Parallels):ScrivWatcher:ScriptingAdditions"
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# generated for envman. do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
