#!/usr/bin/env bash
# shellcheck disable=SC2164

# references:
# - [build vim from source](https://marslo.github.io/ibook/vim/install.html)

source utils.sh

# shellcheck disable=SC2046
function doInOSX() {
  ./configure --with-features=huge \
              --enable-cscope \
              --enable-largefile \
              --enable-rubyinterp=dynamic \
              --with-python3-config-dir=$(python3-config --configdir) \
              --enable-python3interp=dynamic \
              --with-lua-prefix=/usr/local \
              --enable-luainterp=dynamic \
              --enable-libsodium \
              --enable-multibyte \
              --with-tlib=ncurses \
              --enable-terminal \
              --enable-autoservername \
              --enable-nls \
              --with-mac-arch=current \
              --enable-darwin \
              --with-compiledby="marslo <marslo.jiao@gmail.com>" \
              --prefix=/usr/local/vim \
              --exec-prefix=/usr/local/vim \
              --enable-fail-if-missing
  make -j$(nproc)
  sudo make install
  # for kill 9 issue
  sudo cp src/vim /usr/local/vim/bin
}

vimdir='/opt/vim'
git clone https://github.com/vim/vim.git "${vimdir}" && builtin cd -- "${vimdir}"
make clean && make distclean
[[ '1' = "$(isOSX)" ]] && doInOSX

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=indent
