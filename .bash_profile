#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC1090

export BASH_SILENCE_DEPRECATION_WARNING=1

if [[ 'Darwin' = "$(/usr/bin/uname -s)" ]]; then
  test -f /opt/homebrew/bin/brew && eval "$(/opt/homebrew/bin/brew shellenv)"
  test -f /usr/local/bin/brew    && eval "$(/usr/local/bin/brew shellenv)"
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# set -a; source "/Users/marslo/.marslo/.marslorc"; set +a;         # `-a`: mark variables which are modified or created for export
# set -x; source "/Users/marslo/.marslo/.marslorc"; set +x;         # `-x`: print commands and their arguments as they are executed
# bash -ixlc : 2>&1 | grep ...                                      # debug bash full start process : https://unix.stackexchange.com/a/322468/29178
test -f "$HOME/.marslo/.marslorc" && source "$HOME/.marslo/.marslorc"

# remove empty line:
# - sed '/^$/d'
# - awk 'NF > 0' or awk 'NF'
# remove duplicate line:
# - awk '!x[$0]++'
# - https://stackoverflow.com/a/11532197/2940319
# shellcheck disable=SC2155
if [[ 'Darwin' = "$(/usr/bin/uname -s)" ]]; then
  test -f "$(brew --prefix coreutils)/libexec/gnubin/paste" &&
       export PATH=$( echo "${PATH}" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | "$(brew --prefix coreutils)/libexec/gnubin/paste" -s -d: )

  # shellcheck disable=SC2015
  type -P brew >/dev/null && source "$(brew --prefix git)"/etc/bash_completion.d/git-*.sh \
                          || source "$(brew --prefix git)"/etc/bash_completion.d/git-prompt.sh

  test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
else
  type -P paste >/dev/null &&
       export PATH=$( echo "$PATH" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | paste -s -d: )
fi

test -d "$HOME"/perl5 && eval "$(perl -I"$HOME"/perl5/lib/perl5 -Mlocal::lib="$HOME"/perl5)"

# eval "$(/bin/cat "$HOME/_extract_func_completion")"

# see ~/.marslo/.marslorc
# complete -C /opt/homebrew/bin/vault vault

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
