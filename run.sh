#!/usr/bin/env bash

irc="$HOME/.marslo"
conf='./confs/home'
file="$HOME/.profile"

[[ -d "${irc}"        ]] || mkdir -p "${irc}"
[[ -d "${irc}/bin"    ]] || mkdir -p "${irc}/bin"
[[ -d "${irc}/.alias" ]] || mkdir -p "${irc}/.alias"

# shellcheck disable=SC1083
function macOS() {
  cp -t "${irc}"        "${conf}"/.marslo/.{marslorc,imac,gitalias,gitrc,env,colors,it2colors,bye}
  cp -t "${irc}/.alias" "${conf}"/.marslo/.alias/{imarslo,mac,utils,devops,kubernetes,docker}
}

function unixGeneric() {
  cp -t "${irc}"        "${conf}"/.marslo/.{marslorc,imac,gitalias,gitrc,env,colors,it2colors,bye}
}

function bins() {
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{ifunc,ffunc,ii,ig,irt,im}.sh
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{ff,gdoc,fman,ldapsearch}
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{screenfetch-dev,now,iweather,iweather.icon,diff-highlight,git-info}
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/git-*
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{bash-color,show-color}.sh
  cp -t "${irc}/bin"    "${conf}"/.marslo/bin/{appify,ansi}
}

# shellcheck disable=SC2086
cp -t $HOME "${conf}"/{.screenrc,tig/.tigrc,tmux/.tmux.conf,.tabset,git/.gitconfig,git/.gitignore,git/.gitattributes}
# shellcheck disable=SC2086
cp -t $HOME/.inputrc "${conf}"/inputrc/.inputrc_bash
# shellcheck disable=SC2086
cp -t $HOME -r "${conf}"/{.iStats,.idlerc}

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
source "${file}"
