# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/fzf/bin"
fi

eval "$(fzf --bash)"
