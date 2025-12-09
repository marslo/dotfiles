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
if test 'Darwin' = "$(/usr/bin/uname)"; then
  test -f /opt/homebrew/bin/brew && HOMEBREW_PREFIX="/opt/homebrew";
  test -f /usr/local/bin/brew    && HOMEBREW_PREFIX="/usr/local";
  test -f "${HOMEBREW_PREFIX}"/bin/brew && eval "$("${HOMEBREW_PREFIX}"/bin/brew shellenv 2>/dev/null)"

  if [[ "${BASH:-}" = "${HOMEBREW_PREFIX}/bin/bash" || "${BASH:-}" = "${HOMEBREW_PREFIX}/opt/bash/bin/bash" ]]; then
    command -v brew >/dev/null   && source "${HOMEBREW_PREFIX}"/opt/git/etc/bash_completion.d/git-*.sh \
                                 || source "${HOMEBREW_PREFIX}"/opt/git/etc/bash_completion.d/git-prompt.sh
  fi
else
  test -f "/etc/bash_completion.d/git-prompt"         && source "/etc/bash_completion.d/git-prompt"
  test -f "/usr/local/libexec/git-core/git-prompt.sh" && source "/usr/local/libexec/git-core/git-prompt.sh"
fi

# remove empty line:
# - sed: `sed '/^$/d'`
# - awk: `awk 'NF > 0' or awk 'NF'`
# remove duplicate line: https://stackoverflow.com/a/11532197/2940319
# - awk: `awk '!x[$0]++'`
if [[ 'Darwin' = "$(uname)" ]]; then
  test -f "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin/paste" &&
       export PATH=$( echo "${PATH}" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin/paste" -s -d: )
else
  command -v paste >/dev/null &&
       export PATH=$( echo "${PATH}" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | paste -s -d: )
fi

# ubuntu/wsl
if [[ -f /etc/os-release ]] && [[ 'debian' = $(awk -F '=' '/ID_LIKE/ { print $2 }' /etc/os-release) ]]; then
  export DEBIAN_FRONTEND=noninteractive
fi

# to load .marslorc in nvim terminal
if [[ -n "${NVIM}" ]]; then
  test -f ~/.marslo/.marslorc && source ~/.marslo/.marslorc
fi
function bello() { source ~/.bash_profile; }

# https://brettterpstra.com/2014/07/12/making-cd-in-bash-a-little-better/
# export FIGNORE="Application Scripts:Applications (Parallels):ScrivWatcher:ScriptingAdditions"
if test -f ~/.fzf.bash; then source ~/.fzf.bash; fi
# generated for envman. do not edit.
if test -s "$HOME/.config/envman/load.sh"; then source "$HOME/.config/envman/load.sh"; fi
# generated for tt
if test -f "$HOME/.tt/.ttenv"; then source "$HOME/.tt/.ttenv"; fi

# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
