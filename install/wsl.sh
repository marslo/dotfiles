#!/usr/bin/env bash
# shellcheck source=/dev/null disable=SC2154

source ../.marslo/bin/bash-color.sh

# shellcheck disable=SC2145,SC2124
function log() {
  declare extra=''
  [[ $# -lt 1 ]] && echo -e "$(c Rs)log$(c) function support at least $(c Gs)1$(c) parameters !"
  if [[ '-r' = "$1" ]]; then
    [[ $#-2 -ge 1 ]] && extra="$(c Wd) ${@: 2:$#-2}$(c)"
    echo -e "$(c Wd)>>$(c)${extra} $(c Gis)${@: $#}$(c) $(c Wdi)..$(c)"
  else
    echo -e "$(c Wd)>>$(c) $(c Gis)$1$(c) $(c Wdi)${*: 2} ..$(c)"
  fi
}

sudo usermod -aG root marslo
sudo chown marslo:root /opt

mkdir -p ~/.local/bin/
mkdir -p "${GOPATH}"

chmod +x "${iRCHOME}"/bin/*
chmod 644 "${iRCHOME}"/bin/*.png

proxy='http://proxy.sample.com:8080'
noproxy='*.sample.com,.sample.com,10.69.114.252,10.69.114.249,localhost,127.0.0.1,::1';
pEnv='http_proxy ftp_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY';
for envvar in $pEnv; do export "${envvar}"="${proxy}"; done
export no_proxy="${noproxy}"
log 'proxy' 'has been setup'

log -r 'setup' 'apt-repository'
sudo add-apt-repository -y ppa:aos1/diff-so-fancy
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

log -r 'installing' 'apt packages'
sudo apt install -y bc \
                    ncal \
                    jq \
                    locales \
                    snapd \
                    toilet \
                    figlet \
                    tig \
                    wslu \
                    build-essential \
                    moreutils \
                    wl-clipboard \
                    net-tools \
                    libncurses-dev \           # ncdu
                    checkinstall \             # ╮
                    libbz2-dev \               # │
                    libc6-dev \                # │
                    libexpat1-dev \            # │
                    libgdbm-compat-dev \       # │
                    libgdbm-dev \              # │
                    liblzma-dev                # │
                    libncursesw5-dev \         # ├ python
                    libnss3-dev \              # │
                    libreadline-dev \          # │
                    libreadline8 \             # │
                    libsqlite3-dev \           # │
                    libssl-dev \               # │
                    lzma \                     # │
                    lzma-dev \                 # │
                    pkg-config \               # │
                    tk-dev \                   # ╯
                    libffi-dev \               # ╮ rbenv
                    libyaml-dev \              # ╯
                    docbook2x \                # ╮
                    asciidoc \                 # │
                    libxml2-dev \              # │
                    xmlto \                    # ├ git-doc
                    hunspell \                 # │
                    libhunspell-dev \          # ╯
                    dh-autoreconf \            # ╮
                    libexpat1-dev \            # │
                    gettext \                  # ├ git-core
                    libz-dev \                 # │
                    libcurl4-openssl-dev \     # ╯
                    install-info \             # git-info
                    libao-dev \                # git-others
                    silversearcher-ag \        # ag
                    libarchive-tools \         # bsdtar
                    diff-so-fancy \
                    yamllint \
                    libxml2-utils \            # xmllint
                    neovim \
                    xclip \
                    vim-gtk \
                    apt-file
# sudo apt install -y libcurl4-gnutls-dev        # git-core
sudo apt-file update -y
sudo apt upgrade -y

# locale
log -r setup locale
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

# rust
log rust installation
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# go
log go installing via snap
sudo snap install go --classic
# nodejs
log nodejs installing via snap
sudo snap install node --classic --channel=20
# or sudo apt install shellcheck
log shellcheck installging via snap
sudo snap install --channel=edge shellcheck
# rg
log 'rg/ripgrep' installing via cargo
cargo install ripgrep

# fzf
log fzf installation
# shellcheck disable=SC2086
git clone git@github.com:junegunn/fzf.git /opt/fzf && cd $_ || return
bash install --all
sudo cp /opt/fzf/bin/fzf* /usr/local/bin/
which -a fzf
fzf --version
cd - || return

# fzy
log fzy installation from source
# shellcheck disable=SC2086
git clone git@github.com:jhawthorn/fzy.git /opt/fzy && cd $_ || return
make
sudo make install
which -a fzy
fzy --version
cd - || return

# fd
log 'fd/fdfind' installation via deb package
if [[ ! -f /opt/fd-find_9.0.0-1_amd64.deb ]]; then
  curl --create-dirs -o /opt/fd-find_9.0.0-1_amd64.deb -fsSL http://ftp.osuosl.org/pub/ubuntu/pool/universe/r/rust-fd-find/fd-find_9.0.0-1_amd64.deb
fi
sudo dpkg -i /opt/fd-find_9.0.0-1_amd64.deb
ln -s "$(command -v fdfind)" ~/.local/bin/fd
which -a fd
fd --version

# bat
log 'bat/batcat' installation via deb package
if [[ ! -f /opt/bat-musl_0.24.0_amd64.deb ]]; then
  curl --create-dirs -o /opt/bat-musl_0.24.0_amd64.deb -fsSL https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb
fi
sudo dpkg -i /opt/bat-musl_0.24.0_amd64.deb
which -a bat
bat --version

# cheat.sh
log cht installation
if [[ ! -f ~/.local/bin/cht.sh ]]; then
  curl -fsSL https://cht.sh/:cht.sh --create-dirs -o ~/.local/bin/cht.sh
fi
chmod +x ~/.local/bin/cht.sh
# completion
if [[ ! -f ~/.marslo/.completion/cht.sh ]]; then
  curl --create-dirs -o ~/.marslo/.completion/cht.sh -fsSL https://cheat.sh/:bash_completion
fi
sudo ln -sf "$HOME/.marslo/.completion/cht.sh" /usr/share/bash-completion/completions/cht.sh

# ncdu
log ncdu installation
# shellcheck disable=SC2086
git clone https://code.blicky.net/yorhel/ncdu.git /opt/ncdu && cd $_ || return
sudo snap install zig --classic --beta
make
sudo make install PREFIX=/usr/local
which -a ncdu
ncdu --version
cd - || return

# c
log 'c/bash-colors' installation
git clone git@github.com:ppo/bash-colors.git /opt/bash-color
ln -sf /opt/bash-color/bash-colors.sh "$(realpath "${iRCHOME}"/bin)"/bash-colors.sh
ln -sf /opt/bash-color/demo.sh        "$(realpath "${iRCHOME}"/bin)"/show-colors.sh

# ansi
log ansi installation
# shellcheck disable=SC2086
if [[ ! -f /opt/ansi ]]; then curl -sL git.io/ansi -o /opt/ansi; fi
chmod +x /opt/ansi
ln -sf /opt/ansi "$(realpath "${iRCHOME}"/bin)"/ansi

# openssl 3.1.4
log 'openssl v3.1.4' installation from source
OPENSSL_HOME='/usr/local/ssl'
if [[ ! -d /opt/openssl ]]; then
  # shellcheck disable=SC2086
  git clone --recurse-submodules git@github.com:openssl/openssl.git /opt/openssl && cd $_ || return
fi
git checkout --recurse-submodules --force openssl-3.1.4
cd /opt/openssl || return
# shellcheck disable=SC2016
./config --prefix="${OPENSSL_HOME}" --openssldir="${OPENSSL_HOME}" zlib-dynamic no-ssl3 shared '-Wl,-rpath,$(LIBRPATH)'
make -j "$(nproc)"
sudo make install_sw install_ssldirs
sudo ln -sf /usr/local/ssl/lib64 /usr/local/ssl/lib
/usr/local/ssl/bin/openssl version
cd - || return

# groovy
log groovy install
GROOVY_VERSION='4.0.20'
GROOVY_PATH='/opt/groovy'
[[ -d "${GROOVY_PATH}" ]] || mkdir -p "${GROOVY_HOME}"
curl -fsSL https://groovy.jfrog.io/ui/native/dist-release-local/groovy-zips/apache-groovy-binary-${GROOVY_VERSION}.zip | bsdtar xzf - -C "${GROOVY_PATH}"
ln -sf "${GROOVY_PATH}/groovy-${GROOVY_VERSION}" "${GROOVY_HOME}/current"
log "export GROOVY_HOME=${GROOVY_HOME}/current"

# java
log java install
JAVA_PATH='/opt/java'
JAVA_VERSION='21.0.2'
curl -fsSL https://download.oracle.com/java/${JAVA_VERSION%%.*}/latest/jdk-${JAVA_VERSION%%.*}_linux-x64_bin.tar.gz | tar xzf - -C ${JAVA_PATH}
log "export JAVA_HOME=${JAVA_PATH}/jdk-${JAVA_VERSION}"
log "export CLASSPATH=\".:\$JAVA_HOME/lib:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar\""

# jenkins.war
log download jenkins.war
JENKINS_VERSION='2.451'
curl --create-dirs /opt/classpath/jenkins.war -fsSL https://updates.jenkins.io/download/war/${JENKINS_VERSION}/jenkins.war
log "export CLASSPATH=\"$CLASSATH:/opt/classpath/jenkins.war\""


log 'LD_LIBRARY_PATH OPENSSL_LDFLAGS OPENSSL_INCLUDES OPENSSL_LIBS' environment setup
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/ssl/lib64
export OPENSSL_LDFLAGS='-L/usr/local/ssl/lib64'
export OPENSSL_INCLUDES='-I /usr/local/ssl/include'
export OPENSSL_LIBS='-L/usr/local/ssl/lib64'

# python
log 'python v3.12.2' installation
mkdir -p /opt/python
PYTHON_VERSION='3.12.2'
PYTHON_HOME="/opt/python/Python-${PYTHON_VERSION}"
curl -fsSL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz | tar xzf - -C /opt/python
cd "${PYTHON_HOME}" || return
LDFLAGS="${LDFLAGS} -Wl,-rpath=/usr/local/ssl/lib" \
CFLAGS="${CFLAGS} -I/usr/local/ssl/include" \
./configure --enable-optimizations --enable-shared --with-lto --with-system-expat --with-ensurepip --with-openssl=/usr/local/ssl --with-openssl-rpath=auto
make -j "$(nproc)"
sudo make install
sudo ldconfig -v
sudo -H /usr/local/bin/python3.12 -m pip install --upgrade pip
# sudo update-alternatives --install /usr/bin/python3 python3 "${PYTHON_HOME}"/bin/python3.12 99
cd - || return

# ruby
log 'ruby v3.3.0' installation
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
~/.rbenv/bin/rbenv init
eval "$(rbenv init - bash)"
RUBY_CONFIGURE_OPTS="--with-openssl-dir=/usr/local/ssl" rbenv install 3.3.0
sudo ln -sf /usr/local/ssl/lib64 /usr/local/ssl/lib
rbenv global 3.3.0
gem update --system
which -a ruby
ruby --version

# git
log 'git v2.43.0' installation
python3 -m pip install asciidoc
GIT_VERSION='2.43.0'
GIT_HOME="/opt/git/git-${GIT_VERSION}"
mkdir -p /opt/git
curl -fsSL https://mirrors.edge.kernel.org/pub/software/scm/git/git-"${GIT_VERSION}".tar.gz | tar xzf - -C /opt/git
cd "${GIT_HOME}" || return
./configure --prefix=/usr/local --with-shell="$(command -v bash)" --with-openssl=/usr/local/ssl
make all doc info
sudo make install install-doc install-html install-info
chmod +x "${GIT_HOME}"/contrib/completion/*
sudo ln -sf "${GIT_HOME}"/contrib/completion/git-prompt.sh       /usr/local/libexec/git-core/git-prompt.sh
sudo ln -sf "${GIT_HOME}"/contrib/completion/git-completion.bash /usr/share/bash-completion/completions/git

# neovim
log -r setup neovim
sudo npm install -g neovim
sudo npm install -g doctoc
sudo npm install -g gnomon
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade pynvim
python3 -m pip install --upgrade pylint
python3 -m pip install --upgrade pyflakes
gem install neovim

# kubectl
log kubectl installation
KUBECTL_VERSION="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
SYSTEM_NAME="$(uname | awk '{print tolower($0)}')"
sudo curl -o /usr/local/bin/kubectl -fsSL https://storage.googleapis.com/kubernetes-release/release/"${KUBECTL_VERSION}"/bin/"${SYSTEM_NAME}"/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
# kubecolor, or sudo apt install kubecolor
go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

log -r show 'system settings'
snap list

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=indent
