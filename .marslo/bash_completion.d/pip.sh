
# pip bash completion start
_pip_completion()
{
    local IFS=$' \t\n'
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 "$1" 2>/dev/null ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end


_py_m_pip_completion() { [[ "${COMP_WORDS[1]}" == "-m" && "${COMP_WORDS[2]}" == "pip" ]] || return; if (( COMP_CWORD == 2 )); then COMPREPLY=(pip); return; fi; COMPREPLY=( $( COMP_WORDS="pip ${COMP_WORDS[*]:3}" COMP_CWORD=$(( COMP_CWORD - 2 )) PIP_AUTO_COMPLETE=1 pip 2>/dev/null ) ); }; complete -o default -F _py_m_pip_completion python python3 python3.14
