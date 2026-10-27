#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2015
#=============================================================================
#     FileName : update.sh
#       Author : marslo
#      Created : 2025-11-14 19:43:32
#   LastChange : 2026-10-26 18:58:37
#=============================================================================

set -euo pipefail

# @credit: https://github.com/ppo/bash-colors
# @usage:  or copy & paste the `c()` function from: https://github.com/ppo/bash-colors/blob/master/bash-colors.sh#L3
# shellcheck disable=SC2015
test -f "${HOME}"/.marslo/bin/bash-colors.sh && source "${HOME}"/.marslo/bin/bash-colors.sh || { c() { :; }; }

# shellcheck disable=SC2155
declare -r HERE="$( cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )"
function info() { test $# -eq 2 && extra="$(c 0Wdi)($2)$(c) " || extra=''; echo -e "$(c Ms)>> ${1} ${extra}$(c 0Gi)updated !$(c)"; }
function warn() { test $# -eq 2 && extra="$(c 0Wdi)($2)$(c) " || extra=''; echo -e "$(c Ms)>> ${1} ${extra}$(c 0Ri)failed or timed out !$(c)"; }
# finalize <file>: read a generated completion on stdin and write it to <file> —
# - tabs expanded to 2 spaces
# - trailing whitespace stripped
# - trailing blank lines dropped, a shebang pre-pended only if missing
# - the house vim modeline appended only if missing.
# idempotent: safe on input that already has either.
function finalize() {
  awk '
    function is_shebang(s)  { return s ~ /^#!/ }
    function is_vim(s)      { return s ~ /^[ \t]*#.*[ \t]vim:/ }           # the house vim: modeline
    function is_modeline(s) { return s ~ /^[ \t]*#.*[ \t](vim?|ex):/ }     # any vi: / vim: / ex: modeline
    { gsub(/\t/, "  "); sub(/ +$/, "") }                                   # tabs -> 2 spaces, strip trailing ws
    NR == 1 && !is_shebang($0) { print "#!/usr/bin/env bash"; print "" }   # prepend shebang if missing
    /^$/ { pending++; next }                                               # hold blank lines
    { for (; pending>0; pending--) print ""; print; last = $0 }            # flush blanks; track last non-blank
    END {
      if (is_vim(last)) { }                                                # already has vim: modeline -> nothing
      else if (is_modeline(last))                                          # ex: / vi: present -> append vim:, no blank line
        print "# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:"
      else {                                                               # no modeline -> blank line + vim:
        print ""
        print "# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:"
      }
    }
  ' > "${1:?output path required}"
}

type -P kubectl >/dev/null && { command kubectl completion bash          | finalize "${HERE}"/kubectl.bash      ; info 'kubectl' 'kubectl.bash'     ; }
type -P npm     >/dev/null && { command npm completion                   | finalize "${HERE}"/npm.bash          ; info 'npm'     'npm.bash'         ; }
type -P node    >/dev/null && { command node --completion-bash           | finalize "${HERE}"/completions/node  ; info 'node'    'completions/node' ; }
type -P gh      >/dev/null && { command gh completion -s bash            | finalize "${HERE}"/gh.bash           ; info 'gh cli'  'gh.bash'          ; }
type -P tt      >/dev/null && { command tt completion bash               | finalize "${HERE}"/tt.bash           ; info 'tt' 'tt.bash'               ; }
type -P pipx    >/dev/null && { command register-python-argcomplete pipx | finalize "${HERE}"/pipx.bash         ; info 'pipx' 'pipx.bash' ; }
# type -P pip   >/dev/null && { command pip completion --bash            > "${HERE}"/pip.bash                   ; info 'pip'  'pip.bash'  ; }
# type -P pip   >/dev/null && { printf '\n%s\n' '_py_m_pip_completion() { [[ "${COMP_WORDS[1]}" == "-m" && "${COMP_WORDS[2]}" == "pip" ]] || return; if (( COMP_CWORD == 2 )); then COMPREPLY=(pip); return; fi; COMPREPLY=( $( COMP_WORDS="pip ${COMP_WORDS[*]:3}" COMP_CWORD=$(( COMP_CWORD - 2 )) PIP_AUTO_COMPLETE=1 pip 2>/dev/null ) ); }; complete -o default -F _py_m_pip_completion python python3 python3.14' >> "${HERE}/pip.bash"; info "python3 -m pip"; }
type -P cheat   >/dev/null && { command cheat --completion bash          | finalize "${HERE}"/cheat.bash        ; info 'cheat' 'cheat.bash'       ; }
# re-add the top-level 'cache' subcommand that `bat --completion` drops (bat#2085)
type -P bat     >/dev/null && {
  command bat --completion bash | awk '
    /removed for better UX/ { next }
    /issues\/2085/          { next }
    /^\} && complete -F _bat bat$/ {
      print "\t# re-add the cache subcommand at the first arg (upstream bat drops it, bat#2085)"
      print "\t((cword == 1)) && COMPREPLY+=($(compgen -W \"cache\" -- \"$cur\"))"
    }
    { print }
  ' | finalize "${HERE}"/bat.bash
  info 'bat' 'bat.bash'
}
# add the "generated via" note under the cobra `# bash completion V2 for smctl` header
type -P smctl   >/dev/null && {
  command smctl completion bash | awk '
    { print }
    /^# bash completion V2 for smctl/ { print "# generated via : smctl completion bash > ~/.marslo/bash_completion.d/completions/smctl" }
  ' | finalize "${HERE}"/completions/smctl
  info 'smctl' 'completions/smctl'
}
# $ pipx inject keyring shtab
type -P keyring >/dev/null && {
  if out="$( command keyring --print-completion bash 2>/dev/null )" && [[ -n "${out}" && "${out}" != Install* ]]; then
    printf '%s\n' "${out}" | finalize "${HERE}"/keyring.bash ; info 'keyring' 'keyring.bash'
  elif test -s "${HERE}"/keyring.bash; then
    echo -e "$(c Ms)>> keyring $(c 0Yi)kept existing $(c 0Wdi)(regen needs: pipx inject keyring shtab)$(c)"
  else
    warn 'keyring'
  fi
}

type -P poetry  >/dev/null && {
  command poetry completions bash | sed -E 's/_poetry_[a-f0-9]+_complete/_poetry_complete/g' | finalize "${HERE}"/poetry.bash
  info 'poetry' 'poetry.bash'
}

type -P code    >/dev/null && {
  {
    curl --max-time 10 -fsSL https://github.com/microsoft/vscode/raw/main/resources/completions/bash/code | sed 's/@@APPNAME@@/code/g' | finalize "${HERE}/code.bash.tmp" && \
    mv "${HERE}/code.bash.tmp" "${HERE}/code.bash" && \
    info 'code' 'code.bash'
  } || warn 'code' 'code.bash'
}

type -P cht.sh  >/dev/null && {
  {
    test -d "${HERE}/cht.bash" || mkdir -p "${HERE}/cht.bash" && \

    command curl --max-time 10 -sf cheat.sh/:list          > "${HERE}/cht.bash/cht.bash.txt.tmp" && \
    test -f "${HERE}/cht.bash/cht.bash.txt.tmp"  && mv "${HERE}/cht.bash/cht.bash.txt.tmp" "${HERE}/cht.bash/cht.bash.txt" && \

    command curl --max-time 10 -sf cht.sh/:bash_completion | finalize "${HERE}/cht.bash/cht.bash.org.tmp" && \
    test -f "${HERE}/cht.bash/cht.bash.org.tmp" && mv "${HERE}/cht.bash/cht.bash.org.tmp" "${HERE}/cht.bash/cht.bash.org" && \

    info 'cht.sh' 'cht.bash/cht.bash'
  } || warn 'cht.sh' 'cht.bash/cht.bash'
}

# cleanup
{ test -n "${HERE}" && test -d "${HERE}"; } && fd -t f -d 2 -u '\.tmp$' "${HERE}" -x rm 2>/dev/null || true

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
