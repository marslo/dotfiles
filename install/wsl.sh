#!/usr/bin/env bash

sudo usermod -aG root marslo
mkdir -p ~/.local/bin/
pset

# diff-so-fancy
sudo add-apt-repository -y ppa:aos1/diff-so-fancy
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

sudo apt install -y bc \
                    ncal \
                    jq \
                    locales \
                    snapd \
                    toilet \
                    figlet \
                    tig \
                    build-essential \
                    libncurses-dev \           # ncdu
                    libexpat1-dev \            # ╮
                    libreadline8 \             # │
                    libreadline-dev \          # │
                    libsqlite3-dev \           # │
                    libnss3-dev \              # │
                    libssl-dev \               # │
                    tk-dev \                   # ├ python
                    libgdbm-dev \              # │
                    libc6-dev \                # │
                    libbz2-dev \               # │
                    libncursesw5-dev \         # │
                    checkinstall \             # │
                    pkg-config \               # ╯
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
                    diff-so-fancy \
                    yamllint \
                    libxml2-utils \            # xmllint
                    neovim \
                    apt-file
sudo apt-file update
sudo apt install -y libcurl4-gnutls-dev        # git-core

# locale
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# go
sudo snap install go --classic
# nodejs
sudo snap install node --classic --channel=20
# rg
cargo install ripgrep

# fzf
git clone git@github.com:junegunn/fzf.git /opt/fzf && cd $_
bash install --all
sudo cp /opt/fzf/bin/fzf* /usr/local/bin/
which -a fzf
fzf --version
cd -

# fzy
git clone git@github.com:jhawthorn/fzy.git /opt/fzy && cd $_
make
sudo make install
which -a fzy
fzy --version
cd -

# fd
curl --create-dirs -o /opt/fd-find_9.0.0-1_amd64.deb -fsSL http://ftp.osuosl.org/pub/ubuntu/pool/universe/r/rust-fd-find/fd-find_9.0.0-1_amd64.deb
sudo dpkg -i /opt/fd-find_9.0.0-1_amd64.deb
ln -s $(which fdfind) ~/.local/bin/fd
which -a fd
fd --version

# bat
curl --create-dirs -o /opt/bat-musl_0.24.0_amd64.deb -fsSL https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb
sudo dpkg -i /opt/bat-musl_0.24.0_amd64.deb
which -a bat
bat --version

# cheat.sh
curl -fsSL https://cht.sh/:cht.sh --create-dirs -o ~/.local/bin/cht.sh
chmod +x ~/.local/bin/cht.sh
# completion
curl --create-dirs -o ~/.marslo/.completion/cht.sh -fsSL https://cheat.sh/:bash_completion
sudo ln -sf "$HOME/.marslo/.completion/cht.sh" /usr/share/bash-completion/completions/cht.sh

# ncdu
git clone https://code.blicky.net/yorhel/ncdu.git /opt/ncdu && cd $_
sudo snap install zig --classic --beta
make
sudo make install PREFIX=/usr/local
which -a ncdu
ncdu --version
cd -

# c
git clone git@github.com:ppo/bash-colors.git /opt/bash-color
ln -sf /opt/bash-color/bash-colors.sh $(realpath "${iRCHOME}"/bin)/bash-colors.sh
ln -sf /opt/bash-color/demo.sh        $(realpath "${iRCHOME}"/bin)/show-colors.sh

# ansi
curl -sL git.io/ansi -o /opt/ansi && chmod +x $_
ln -sf /opt/ansi $(realpath "${iRCHOME}"/bin)/ansi

# openssl 3.1.4
git clone --recurse-submodules git@github.com:openssl/openssl.git
git checkout --recurse-submodules openssl-3.1.4
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl zlib-dynamic no-ssl3 shared '-Wl,-rpath,$(LIBRPATH)'
make -j "$(nproc)"
sudo make install_sw install_ssldirs
/usr/local/ssl/bin/openssl version
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OPENSSL_HOME/lib64
export OPENSSL_LDFLAGS='-L/usr/local/ssl/lib64'
export OPENSSL_INCLUDES='-I /usr/local/ssl/include'
export OPENSSL_LIBS='-L/usr/local/ssl/lib64'

# python
PYTHON_VERSION='3.12.2'
PYTHON_HOME="/opt/python/Python-${PYTHON_VERSION}"
mkdir -p /opt/python
curl -fsSL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz | tar xzf - -C /opt/python
cd "${PYTHON_HOME}"
LDFLAGS="${LDFLAGS} -Wl,-rpath=/usr/local/ssl/lib" \
CFLAGS="${CFLAGS} -I/usr/local/ssl/include" \
./configure --enable-optimizations --enable-shared --with-lto --with-system-expat --with-ensurepip --with-openssl=/usr/local/ssl --with-openssl-rpath=auto
make -j "$(nproc)"
sudo make install
sudo ldconfig -v
# sudo update-alternatives --install /usr/bin/python3 python3 "${PYTHON_HOME}"/bin/python3.12 99
# sudo -H /usr/local/bin/python3.12 -m pip install --upgrade pip

# ruby
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
~/.rbenv/bin/rbenv init
eval "$(rbenv init - bash)"
RUBY_CONFIGURE_OPTS="--with-openssl-dir=/usr/local/ssl" rbenv install 3.3.0
sudo ln -sf /usr/local/ssl/lib64 /usr/local/ssl/lib
rbenv global 3.3.0
which -a ruby
ruby --version

# git
pip install asciidoc
GIT_VERSION='2.43.0 '
GIT_HOME="/opt/git/git-${GIT_VERSION}"
mkdir -p /opt/git
curl -fsSL https://mirrors.edge.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz | tar xzf - -C /opt/git
cd ${GIT_HOME}
./configure --prefix=/usr/local --with-shell=$(command -v bash) --with-openssl=/usr/local/ssl
make all doc info
sudo make install install-doc install-html install-info
chmod +x ${GIT_HOME}/git/contrib/completion/*
sudo ln -sf ${GIT_HOME}/git/contrib/completion/git-prompt.sh       /usr/local/libexec/git-core/git-prompt.sh
sudo ln -sf ${GIT_HOME}/git/contrib/completion/git-completion.bash /usr/share/bash-completion/completions/git

# neovim
gem install neovim
