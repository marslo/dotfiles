#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2164

## references:
## - [install python from source](https://marslo.github.io/ibook/programming/python/config.html#install-from-source-code)
## - [Index of /ftp/python/](https://www.python.org/ftp/python/)

source ./utils.sh

function preInstall() {
  if [[ 1 = "$(isCentOS)" ]] || [[ 1 = "$(isRHEL)" ]]; then
    sudo dnf groupinstall 'development tools'
    sudo dnf install bzip2-devel expat-devel gdbm-devel \
             ncurses-devel openssl-devel readline-devel wget \
             sqlite-devel tk-devel xz-devel zlib-devel libffi-devel
  elif [[ 1 = "$(isUbuntu)" ]] ; then
    echo ".."
  elif [[ 1 = "$(isOSX)" ]]; then
    echo ".."
  fi
}

# shellcheck disable=SC2046
function doInstall() {
  ./configure --enable-optimizations \
              --enable-shared \
              --with-lto \
              --with-system-expat \
              --with-ensurepip
  sudo make -j$(nproc)
  sudo make altinstall
}

function postInstall() {
  sudo -H /usr/local/bin/python3 -m pip install --upgrade pip
  echo """
  >> add following environment variable in .bashrc or .bash_profile :
     export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/python/Python-${pythonver}
  """
}

pythondir='/opt/python'
pythonver='3.12.1'

[[ -d "${pythondir}" ]] || mkdir -p "${pythondir}"
curl -fsSL https://www.python.org/ftp/python/"${pythonver}"/Python-${pythonver}.tar.xz |
    tar xJf - -C "${pythondir}" &&
    cd "${pythondir}/Python-${pythonver}"

preInstall
doInstall
postInstall

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=indent
