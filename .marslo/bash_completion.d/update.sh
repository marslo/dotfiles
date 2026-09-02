#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2015
#=============================================================================
#     FileName : update.sh
#       Author : marslo
#      Created : 2025-11-14 19:43:32
#   LastChange : 2026-09-02 03:43:49
#=============================================================================

set -euo pipefail

# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from:
#          https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${HOME}"/.marslo/bin/bash-colors.sh && source "${HOME}"/.marslo/bin/bash-colors.sh || { c() { :; }; }

# shellcheck disable=SC2155
declare -r HERE="$( cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )"
function info() { echo -e "$(c Ms)>> $1 $(c 0Gi)updated !$(c)"; }
function warn() { echo -e "$(c Ms)>> $1 $(c 0Ri)failed or timed out !$(c)"; }

type -P kubectl >/dev/null && { command kubectl completion bash          > "${HERE}"/kubectl.sh        ; info "kubectl" ; }
type -P npm     >/dev/null && { command npm completion                   > "${HERE}"/npm.sh            ; info "npm"     ; }
type -P gh      >/dev/null && { command gh completion -s bash            > "${HERE}"/gh.bash.sh        ; info "gh cli"  ; }
type -P bat     >/dev/null && {
  {
    printf '#!/usr/bin/env bash\n\n'
    # re-add the top-level 'cache' subcommand that `bat --completion` drops (bat#2085)
    command bat --completion bash | awk '
      /removed for better UX/ { next }
      /issues\/2085/          { next }
      /^\} && complete -F _bat bat$/ {
        print "\t# re-add the cache subcommand at the first arg (upstream bat drops it, bat#2085)"
        print "\t((cword == 1)) && COMPREPLY+=($(compgen -W \"cache\" -- \"$cur\"))"
      }
      { print }
    '
  } > "${HERE}"/bat.sh
  info "bat"
}
type -P pipx    >/dev/null && { command register-python-argcomplete pipx > "${HERE}"/pipx.sh           ; info "pipx"    ; }
# type -P pip   >/dev/null && { command pip completion --bash            > "${HERE}"/pip.sh            ; info "pip"     ; }
# shellcheck disable=SC2016
# type -P pip   >/dev/null && { printf '\n%s\n' '_py_m_pip_completion() { [[ "${COMP_WORDS[1]}" == "-m" && "${COMP_WORDS[2]}" == "pip" ]] || return; if (( COMP_CWORD == 2 )); then COMPREPLY=(pip); return; fi; COMPREPLY=( $( COMP_WORDS="pip ${COMP_WORDS[*]:3}" COMP_CWORD=$(( COMP_CWORD - 2 )) PIP_AUTO_COMPLETE=1 pip 2>/dev/null ) ); }; complete -o default -F _py_m_pip_completion python python3 python3.14' >> "${HERE}/pip.sh"; info "python3 -m pip"; }
type -P cheat   >/dev/null && { command cheat --completion bash          > "${HERE}"/cheat.sh          ; info "cheat"   ; }
type -P smctl   >/dev/null && { command smctl completion bash            > "${HERE}"/completions/smctl ; info "smctl"   ; }
# $ pipx inject keyring shtab
type -P keyring >/dev/null && {
  if out="$( command keyring --print-completion bash 2>/dev/null )" && [[ -n "${out}" && "${out}" != Install* ]]; then
    printf '#!/usr/bin/env bash\n\n%s\n' "${out}" > "${HERE}"/keyring.bash ; info "keyring"
  elif [[ -s "${HERE}"/keyring.bash ]]; then
    echo -e "$(c Ms)>> keyring $(c 0Yi)kept existing $(c 0Wdi)(regen needs: pipx inject keyring shtab)$(c)"
  else
    warn "keyring"
  fi
}
type -P tt      >/dev/null && { command tt completion bash               > "${HERE}"/tt.bash           ; info "tt"      ; }

type -P poetry  >/dev/null && {
  command poetry completions bash | sed -E 's/_poetry_[a-f0-9]+_complete/_poetry_complete/g' > "${HERE}"/poetry.sh
  info "poetry"
}

type -P code    >/dev/null && {
  {
    curl --max-time 10 -fsSL https://github.com/microsoft/vscode/raw/main/resources/completions/bash/code | \
         sed 's/@@APPNAME@@/code/g' > "${HERE}/code.sh.tmp" && \
    mv "${HERE}/code.sh.tmp" "${HERE}/code.sh" && \
    info "code"
  } || warn "code"
}

type -P cht.sh  >/dev/null && {
  {
    command curl --max-time 10 -sf cheat.sh/:list          > "${HERE}/cht.sh/cht.sh.txt.tmp" && \
    mv "${HERE}/cht.sh/cht.sh.txt.tmp" "${HERE}/cht.sh/cht.sh.txt" && \

    command curl --max-time 10 -sf cht.sh/:bash_completion > "${HERE}/cht.sh/cht.sh.org.tmp" && \
    mv "${HERE}/cht.sh/cht.sh.org.tmp" "${HERE}/cht.sh/cht.sh.org" && \

    info "cht.sh"
  } || warn "cht.sh"
}

# cleanup
[[ -n "${HERE}" && -d "${HERE}" ]] && fd -t f -d 2 -u '\.tmp$' "${HERE}" -x rm 2>/dev/null || true

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
