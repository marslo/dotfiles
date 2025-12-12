#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC1090

export BASH_SILENCE_DEPRECATION_WARNING=1

if test 'Darwin' = "$(/usr/bin/uname -s)"; then
  test -f /opt/homebrew/bin/brew && HOMEBREW_PREFIX="/opt/homebrew"
  test -f /usr/local/bin/brew    && HOMEBREW_PREFIX="/usr/local"

  # fix issue in vscode / cursor : `Unable to resolve your shell environment: Unexpected exit code from spawned shell (code 9, signal null)`
  if [[ -n "${VSCODE_RESOLVING_ENVIRONMENT}" ]]; then
    if [[ -n "${HOMEBREW_PREFIX}" ]]; then
      export PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}"
      export MANPATH="${HOMEBREW_PREFIX}/share/man:${MANPATH}"
      export INFOPATH="${HOMEBREW_PREFIX}/share/info:${INFOPATH}"
    fi
    return 0 2>/dev/null
  fi

  test -f "${HOMEBREW_PREFIX}"/bin/brew && eval "$("${HOMEBREW_PREFIX}"/bin/brew shellenv 2>/dev/null)"
  test -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"      && source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  test -r "${HOMEBREW_PREFIX}/share/bash-completion/bash_completion" && source "${HOMEBREW_PREFIX}/share/bash-completion/bash_completion"
fi

# set -a; source "$HOME/.marslo/.marslorc"; set +a;   # `-a`: mark variables which are modified or created for export
# set -x; source "$HOME/.marslo/.marslorc"; set +x;   # `-x`: print commands and their arguments as they are executed
# bash -ixlc : 2>&1 | grep ...                        # debug bash full start process : https://unix.stackexchange.com/a/322468/29178
test -f "$HOME/.marslo/.marslorc" && source "$HOME/.marslo/.marslorc"

# remove empty line:
# - sed: `sed '/^$/d'`
# - awk: `awk 'NF > 0'` or `awk 'NF'`
# remove duplicate line: https://stackoverflow.com/a/11532197/2940319
# - awk: `awk '!x[$0]++'`
# shellcheck disable=SC2155
if test 'Darwin' = "$(/usr/bin/uname -s)"; then
  test -f "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin/paste" &&
       export PATH=$( echo "${PATH}" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin/paste" -s -d: )
  # shellcheck disable=SC2015
  type -P brew >/dev/null && source "${HOMEBREW_PREFIX}"/opt/git/etc/bash_completion.d/git-*.sh \
                          || source "${HOMEBREW_PREFIX}"/opt/git/etc/bash_completion.d/git-prompt.sh
else
  type -P paste >/dev/null &&
       export PATH=$( echo "$PATH" | tr ':' '\n' | awk 'NF' | awk '!x[$0]++' | paste -s -d: )
fi

# to avoid exit code non-zero if path not exist
if test -d "$HOME"/perl5; then eval "$(perl -I"$HOME"/perl5/lib/perl5 -Mlocal::lib="$HOME"/perl5)"; fi
if test -f "$HOME"/_extract_func_completion; then eval "$(/bin/cat "$HOME/_extract_func_completion")"; fi

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
