#!/usr/bin/env bash
# shellcheck disable=SC2164

## references:
## - [install git from source](https://marslo.github.io/ibook/devops/git/config.html#from-source)
## - [Index of /pub/software/scm/git](https://mirrors.edge.kernel.org/pub/software/scm/git/)

source ./utils.sh

function preInstall() {
  if [[ 1 = "$(isCentOS)" ]] || [[ 1 = "$(isRHEL)" ]]; then
    # git-core
    sudo dnf config-manager --set-enabled powertools
    sudo dnf install epel-release epel-next-release
    sudo dnf install -y dh-autoreconf libcurl-devel curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel
    # git-doc
    sudo dnf install -y asciidoc xmlto docbook-style-xsl
    sudo dnf install -y --enablerepo=*epel* docbook2X
    sudo ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi
    # git-info
    sudo dnf install -y util-linux libao libao-devel
  elif [[ 1 = "$(isUbuntu)" ]] ; then
    # git-core
    sudo apt install -y dh-autoreconf libexpat1-dev gettext libz-dev libssl-dev
    sudo apt install -y libcurl4-openssl-dev
    # sudo apt install -y libcurl4-gnutls-dev
    # git-doc
    sudo apt install -y asciidoc xmlto docbook2x hunspell libhunspell-dev
    # git-info
    sudo apt install -y install-info libao-dev
  elif [[ 1 = "$(isOSX)" ]]; then
    brew install gcc autoconf automake openssl@3 expat gettext zlib libtool libiconv ncurses
    brew install asciidoc xmlto docbook2x docbook-xsl hunspell
    brew install gnu-getopt libao
    sudo ln -sf /usr/local/bin/docbook2texi /usr/local/bin/docbook2x-texi
  fi
}

function doInstall() {
  make configure
  ./configure --prefix=/usr/local --with-shell=$(command -v bash)
  make -j all doc info
  sudo make install install-doc install-html install-info
}

function doInstallWithOpenssl() {
  make configure
  ./configure --prefix=/usr/local --with-shell=$(command -v bash) --with-openssl=/usr/local/ssl
  make -j all doc info
  sudo make install install-doc install-html install-info
}

gitdir='/opt/git'
gitver='2.43.0'

[[ -d "${gitdir}" ]] || mkdir -p "${gitdir}"
curl -fsSL https://mirrors.edge.kernel.org/pub/software/scm/git/git-${gitver}.tar.gz |
     tar xzf - -C "${gitdir}" &&
     cd "${gitdir}/git-${gitver}"

preInstall
doInstall

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
