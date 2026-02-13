#!/usr/bin/env bash
# shellcheck disable=SC1090
#=============================================================================
#     FileName : install.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2021-08-11 22:13:38
#   LastChange : 2025-10-27 19:47:19
#=============================================================================

# shellcheck disable=SC1091
source ./.marslo/bin/bash-color.sh

irc="$HOME/.marslo"
dotfolder='.'
CP="$(type -P cp)"
timestamp="$(date +%y%m%d%H%M%S)"

function isWSL()     { uname -r | command grep --color=never -q -i 'microsoft'; }
function isOSX()     { test 'Darwin' = "$(uname -s)"; }
function isLinux()   { ! isWSL && test 'Linux' = "$(uname -s)"; }

function message() {
  [[ 2 != "$#" ]] && echo -e "$(c Rs)ERROR: must provide two parameters to message function$(s). Exit .." && exit 1

  local msg="$2"
  if [[ 'warn' = "${type}" ]]; then
    echo -e "$(c Rs)>> $(c Rsn)WARNING$(c) : $(c Rs)${msg}. SKIP ..$(c)"
  elif [[ 'info' = "${type}" ]]; then
    echo -e "$(c Bs)>> INFO   $(c) : ${msg}"
  fi
}

# shellcheck disable=SC2086
function doCopy() {
  [[ 2 -gt "$#" ]] && echo -e "$(c Rs)ERROR: \`message\` function requires at least 2 parameters!$(s). Exit .." && exit 1
  local target="$1"
  local sources=${*: 2}
  local opt='-t'

  while read -r source; do

    if [[ -e "${source}" ]]; then
      name="$(basename ${source})"
      if [[ -e "${target}/${name}" ]]; then
        message 'warn' "target: '${target}/${name}' already EXISTS. Copy manually."
      else
        message 'info' "copy ${source} to ${target}"
        [[ -d "${source}" ]] && opt='-r -t'
        [[ -d "${target}" ]] || mkdir -p "${target}"
        eval "${CP} ${opt} '${target}' '${source}'"
      fi
    else
      message 'warn' "source: '${source}' CANNOT be found"
    fi

  done < <( echo "${sources}" | fmt -1 )
}

function backup() {
  [[ -d "${irc}"        ]] && mv "${irc}"{,."${timestamp}"}
  [[ -d "${irc}/bin"    ]] && mv "${irc}/bin"{,."${timestamp}"}
  [[ -d "${irc}/.alias" ]] && mv "${irc}/.alias"{,."${timestamp}"}
  [[ -d "$HOME/.docker" ]] && mv "$HOME/.docker"{,."${timestamp}"}
  [[ -d "$HOME/.config" ]] && mv "$HOME/.config"{,."${timestamp}"}
}

function createDir() {
  [[ -d "${irc}"        ]] || mkdir -p "${irc}"
  [[ -d "${irc}/bin"    ]] || mkdir -p "${irc}/bin"
  [[ -d "${irc}/.alias" ]] || mkdir -p "${irc}/.alias"
  [[ -d "$HOME/.docker" ]] || mkdir -p "$HOME/.docker"
  [[ -d "$HOME/.config" ]] || mkdir -p "$HOME/.config"
}

function dotConfig() {
  if [[ ! -d "$HOME"/.config/nvim ]]; then
    doCopy "$HOME/.config" "${dotfolder}"/.config/nvim
  fi
  doCopy "$HOME"         "${dotfolder}"/.idlerc
  doCopy "$HOME"         "${dotfolder}"/.{gitconfig,gitignore,gitattributes,fdignore,rgignore,ctags}
  doCopy "$HOME"         "${dotfolder}"/.{screenrc.wgetrc,tigrc,curlrc,inputrc.shellcheckrc}
  doCopy "$HOME/.docker" "${dotfolder}"/.docker/daemon.json
}

function generic() {
  doCopy "${irc}"        "${dotfolder}"/.marslo/vimrc.d
  doCopy "${irc}"        "${dotfolder}"/.marslo/.{env,gitrc,colors,bye}
  doCopy "${irc}"        "${dotfolder}"/.marslo/.{it2colors,it2colors.css,.it2colorname}
  doCopy "${irc}/.alias" "${dotfolder}"/.marslo/.alias/{utils,kubernetes,docker}
}

function bins() {
  doCopy "${irc}/bin"    "${dotfolder}"/.marslo/bin/{ifunc,ig}.sh
  doCopy "${irc}/bin"    "${dotfolder}"/.marslo/bin/{ff,gdoc,fman}
  doCopy "${irc}/bin"    "${dotfolder}"/.marslo/bin/{screenfetch-dev,now,iweather.icon,diff-highlight,git-info,ansi}
  doCopy "${irc}/bin"    "${dotfolder}"/.marslo/bin/git-*
  doCopy "${irc}/bin"    "${dotfolder}"/.marslo/bin/{bash-color,show-color}.sh
}

function completion() {
  mkdir -p "${irc}/completion"
  ln -sf "$(realpath "${dotfolder}"/.marslo/.completion)" "${irc}/completion"
}

function special() {
  if isOSX; then
    doCopy "${irc}"        "${dotfolder}"/.marslo/.imac
    doCopy "${irc}/.alias" "${dotfolder}"/.marslo/.alias/mac
    doCopy "${irc}/bin"    "${dotfolder}"/.marslo/bin/{appify,ii.sh}
  elif isWSL; then
    doCopy "${irc}"        "${dotfolder}"/.marslo/.iwsl
  elif isLinux; then
    doCopy "${irc}"        "${dotfolder}"/.marslo/.irhel
  fi
}

# shellcheck disable=SC2086
function encryptFiles() {
  local binCurrent='iweather ffunc.sh now gdoc ldapsearch irt.sh im.sh'
  local aliasCurrent='deovps imarslo'
  local rcCurrent='.bash_profile .profile'
  local rcFiles='.gitalias .token .netrc'
  local confFiles='.pip/pip.config .docker/config.json .ssh/config'

  while read -r _file; do
    doCopy "$HOME/${_file}" "${dotfolder}"/"${_file}".current
  done < <( echo "${rcCurrent}" | fmt -1 )
  while read -r _file; do
    doCopy "${irc}/bin/${_file}" "${dotfolder}"/.marslo/bin/"${_file}".current
  done < <( echo "${binCurrent}" | fmt -1 )

  while read -r _file; do
    doCopy "${irc}/.alias/${_file}" "${dotfolder}"/.marslo/.alias/"${_file}".current
  done < <( echo "${aliasCurrent}" | fmt -1 )

  while read -r _file; do
    dir=$(dirname "${_file}")
    [[ -d "$HOME/${dir}" ]] || mkdir -p "$HOME/${dir}"
    doCopy "$HOME"/"${_file}" "${dotfolder}/${_file}"
  done < <( echo "${confFiles}" | fmt -1 )

  while read -r _file; do
    doCopy "${irc}/${_file}" "${dotfolder}"/.marslo/"${_file}"
  done < <( echo "${rcFiles}" | fmt -1 )

  echo -e "$(c Ms)>> decrypt following files manually $(c) :"
  echo -e "$(c Msi)$ command vim $(echo ${confFiles}    | fmt -1 | xargs -I{} bash -c "echo $HOME/{}"         | xargs )$(c)"
  echo -e "$(c Msi)$ command vim $(echo ${rcFiles}      | fmt -1 | xargs -I{} bash -c "echo ${irc}/{}"        | xargs )$(c)"
  echo -e "$(c Msi)$ command vim $(echo ${rcCurrent}    | fmt -1 | xargs -I{} bash -c "echo $HOME/{}"         | xargs )$(c)"
  echo -e "$(c Msi)$ command vim $(echo ${binCurrent}   | fmt -1 | xargs -I{} bash -c "echo ${irc}/bin/{}"    | xargs )$(c)"
  echo -e "$(c Msi)$ command vim $(echo ${aliasCurrent} | fmt -1 | xargs -I{} bash -c "echo ${irc}/.alias/{}" | xargs )$(c)"
}

function others(){
  # for fzf-git.sh
  [[ -d "${irc}"/utils/fzf-plugins/fzf-git.sh ]] || mkdir -p "${irc}"/utils/fzf-plugins/fzf-git.sh
  git clone https://github.com/junegunn/fzf-git.sh.git    "${irc}"/utils/fzf-plugins/fzf-git.sh
  ln -sf "${irc}"/utils/fzf-plugins/fzf-git.sh/fzf-git.sh "${irc}"/bin/fzf-git.sh

  # for bash-colors.sh
  [[ -d "${irc}"/utils/bash-colors ]] &&  mkdir -p "${irc}"/utils/bash-colors
  git clone https://github.com/ppo/bash-colors.git "${irc}"/utils/bash-colors
  chmod +x "${irc}"/utils/bash-colors/*.sh
  [[ -f "${irc}"/bin/bash-colors.sh ]] ||
  ln -sf "${irc}"/utils/bash-color/bash-colors.sh  "${irc}"/bin/bash-colors.sh
  [[ -f "${irc}"/bin/show-colors.sh ]] ||
  ln -sf "${irc}"/utils/bash-color/demo.sh         "${irc}"/bin/show-colors.sh
}

while true; do
  read -r -p "Do you want backup folders to avoid replaced [Y/N]: " yn
  case $yn in
      [Yy]* ) backit=1 ; break                          ;;
      [Nn]* ) backit=0 ; break                          ;;
          * ) echo "only allows Y or N, ctrl-c to exit" ;;
  esac
done

[[ 1 = "${backit}"   ]] && backup && createDir
[[ true = "$(isWSL)" ]] && mrc='.marslorc.wsl' || mrc='.marslorc'

dotConfig
generic
bins
special
encryptFiles
others

localrc=''
[[ 'true' = "$(isWSL)" ]] && localrc=".bashrc" || localrc=".bash_profile"
if [[ -f "$HOME/${localrc}" ]]; then
  echo "[ -f \"${irc}/${mrc}\"] && source \"${irc}/${mrc}\"" >> "$HOME/${localrc}"
else
  doCopy "$HOME" "${dotfolder}"/"${localrc}"
  [[ true = "$(isWSL)" ]] && sed -r 's/\.marslorc/\.marslorc.wsl/g' -i "$HOME/${localrc}"
fi
source "${localrc}"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
