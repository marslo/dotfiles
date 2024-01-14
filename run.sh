#!/usr/bin/env bash

irc="$HOME/.marslo"
conf='./confs/home'
file="$HOME/.profile"

[[ -d "${irc}"        ]] || mkdir -p "${irc}"
[[ -d "${irc}/bin"    ]] || mkdir -p "${irc}/bin"
[[ -d "${irc}/.alias" ]] || mkdir -p "${irc}/.alias"

function isWSL() {
  if ! uname -r | grep -q "Microsoft"; then echo true; fi
}

# shellcheck disable=SC1083
function macOS() {
  cp -t "${irc}"        "${conf}"/.marslo/.{marslorc,imac,gitalias,gitrc,env,colors,it2colors,bye}
  cp -t "${irc}/.alias" "${conf}"/.marslo/.alias/{imarslo,mac,utils,devops,kubernetes,docker}
}

function unixGeneric() {
  cp -t "${irc}"        "${conf}"/.marslo/.{marslorc,imac,gitalias,gitrc,env,colors,it2colors,bye}
  cp -rt "${irc}"       "${conf}"/.marslo/vimrc.d
}

function bins() {
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{ffunc,ii,ig,irt,im}.sh
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{ff,gdoc,fman,ldapsearch}
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{screenfetch-dev,now,iweather.icon,diff-highlight,git-info}
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/git-*
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{bash-color,show-color}.sh
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{appify,ansi}
}

function encryptFile() {
  files='iweather ifunc.sh now gdoc ldapsearch'
  if [[ 'true' = isWSL ]]; then
    files+=' im.wsl.sh'
  else
    files+=' im.sh'
  fi
  while read -r _file; do
    cp -t "${irc}/bin/${_file}" "${conf}"/.marslo/bin/"${_file}".current
  done < <( echo "" | fmt -1 )

}

function dotConfig() {
  # shellcheck disable=SC2086
  cp -rt $HOME "${conf}"/{.config/nvim,tig/.tigrc,tmux/.tmux.conf,git/.gitconfig,git/.gitignore,git/.gitattributes}
  # shellcheck disable=SC2086
  cp -t $HOME/.inputrc "${conf}"/.inputrc
  # shellcheck disable=SC2086
  cp -t $HOME -r "${conf}"/.{screenrc,iStats,idlerc,fdignore,rgignore}
}

[ -f "$HOME/.gitconfig" ] && cat >> "$HOME/.gitconfig" << EOF
[include]
  path = "${irc}/.gitalias"
EOF

# https://github.com/KittyKatt/screenFetch/issues/692#issuecomment-726631900
if [[ -x /usr/bin/sw_vers ]] && /usr/bin/sw_vers | grep -E '\s*[mM]ac\s*OS\s*X?' >/dev/null; then
  file="$HOME/.bash_profile"
elif [ -f '/etc/os-release' ]; then
  distrab=$(awk -F= '$1=="ID" {print $2;}' /etc/lsb-release)
  [ 'ubuntu' == "${distrab}" ] || [ 'centos' == "${distrab}" ] && file="$HOME/.bashrc"
fi

echo "[ -f \"${irc}\"/.marslorc ] && source \"${irc}\"/.marslorc" >> ~/.bashrc
# shellcheck disable=SC1090
source "${file}"
