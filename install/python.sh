#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2164

## references:
## - [install python from source](https://marslo.github.io/ibook/programming/python/config.html#install-from-source-code)
## - [Index of /ftp/python/](https://www.python.org/ftp/python/)
## - [Setup and building - Install dependencies](https://devguide.python.org/getting-started/setup-building/index.html#install-dependencies)

source ./utils.sh
source ../.marslo/bin/bash-color.sh

declare OPENSSL_HOME='/usr/local/ssl'
declare PYTHON_DIR='/opt/python'
declare PYTHON_VERSION='3.12.1'

function preInstall() {
  if isCentOS || isRHEL; then
    sudo dnf groupinstall 'development tools'
    sudo dnf install bzip2-devel expat-devel gdbm-devel \
             ncurses-devel openssl-devel readline-devel wget \
             sqlite-devel tk-devel xz-devel zlib-devel libffi-devel
  elif isUbuntu; then
    sudo apt update -y
    sudo apt install -y build-essential checkinstall gdb lcov \
                        libbz2-dev libc6-dev libexpat1-dev libffi-dev \
                        libgdbm-compat-dev libgdbm-dev liblzma-dev \
                        libncursesw5-dev libnss3-dev libreadline-dev \
                        libreadline8 libsqlite3-dev libssl-dev \
                        lzma lzma-dev pkg-config tk-dev uuid-dev zlib1g-dev
  elif isOSX; then
    xcode-select --install
    GDBM_CFLAGS="-I$(brew --prefix gdbm)/include" \
    GDBM_LIBS="-L$(brew --prefix gdbm)/lib -lgdbm" \
    ./configure --with-pydebug --with-openssl="$(brew --prefix openssl@3)"
    make regen-configure
  fi
}

# openssl 3.1.4
function buildOpenssl() {
  git clone --recurse-submodules git@github.com:openssl/openssl.git /opt/openssl && cd $_
  git checkout --recurse-submodules --force openssl-3.1.4
  cd /opt/openssl
  ./config --prefix="${OPENSSL_HOME}" --openssldir="${OPENSSL_HOME}" zlib-dynamic no-ssl3 shared '-Wl,-rpath,$(LIBRPATH)'
  make -j "$(nproc)"
  sudo make install_sw install_ssldirs
  sudo ln -sf ${OPENSSL_HOME}/lib64 ${OPENSSL_HOME}/lib
  ${OPENSSL_HOME}/bin/openssl version
  cd -
}

function buildEnv() {
  buildOpenssl
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/ssl/lib64
  export OPENSSL_LDFLAGS='-L/usr/local/ssl/lib64'
  export OPENSSL_INCLUDES='-I /usr/local/ssl/include'
  export OPENSSL_LIBS='-L/usr/local/ssl/lib64'
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
  sudo ldconfig -v
}

function doInstallWithOpenssl() {
  buildEnv
  LDFLAGS="${LDFLAGS} -Wl,-rpath=/usr/local/ssl/lib" \
  CFLAGS="${CFLAGS} -I/usr/local/ssl/include" \
  ./configure --enable-optimizations \
              --enable-shared \
              --with-lto \
              --with-system-expat \
              --with-ensurepip \
              --with-openssl=/usr/local/ssl \
              --with-openssl-rpath=auto

  make -j "$(nproc)"
  sudo make install
  sudo ldconfig -v
}

function postInstall() {
  sudo -H /usr/local/bin/python3 -m pip install --upgrade pip
  /usr/local/bin/python3 -m pip install --upgrade pip
  echo """
  >> add following environment variable in .bashrc or .bash_profile :
     export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/python/Python-${PYTHON_VERSION}
  """
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/python/Python-${PYTHON_VERSION}
  python3 -m pip install --upgrade pynvim
  python3 -m pip install --upgrade pylint
  python3 -m pip install --upgrade pyflakes
}

[[ -d "${PYTHON_DIR}" ]] || mkdir -p "${PYTHON_DIR}"
curl -fsSL https://www.python.org/ftp/python/"${PYTHON_VERSION}"/Python-${PYTHON_VERSION}.tar.xz |
    tar xJf - -C "${PYTHON_DIR}" &&
    cd "${PYTHON_DIR}/Python-${PYTHON_VERSION}"

preInstall
# doInstall
doInstallWithOpenssl
postInstall

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=indent
