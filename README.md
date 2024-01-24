🛠 dotfiles for Vim/CMD enthusiast
==========

>
> 为者常成, 成难成之事; 行者常至, 至难至之地. 与君共勉之! <br>
>                                           - [晏子春秋](https://web.archive.org/web/20061018194424/http://www.chinapage.com/big5/classic/yj0.htm)
>
>
> Whoever will eventually shake the world will remain silent for a long time;<br>
> Whoever will eventually light the lightning will be drifting like clouds for a long time.<br>
>                                           - [Nietzsche](https://www.aphorismen.de/zitat/5992)

<br>

Life is short, make it easier!
--------------

## version
- Author: marslo
- Email: marslo.jiao@gmail.com
- Created: 2013-10-07 21:43:42
- LastChange: 2024-01-24 00:43:55

## table of content
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [setup](#setup)
- [folder structure](#folder-structure)
- [manual configure](#manual-configure)
  - [`~/.marslo/.marslorc`](#marslomarslorc)
  - [inputrc:](#inputrc)
  - [nvim](#nvim)
  - [gitalias](#gitalias)
  - [tig](#tig)
  - [python IDLE](#python-idle)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<br>

![ffunc.sh](https://github.com/marslo/dotfiles/raw/assets/screenshots/ffunc.sh.gif)

![LS_COLORS](https://github.com/marslo/dotfiles/raw/assets/screenshots/LS_COLORS.png)

![LS_COLORS_ALL](https://github.com/marslo/dotfiles/raw/assets/screenshots/LS_COLORS_ALL.png)

## setup
### dotfiles
```bash
$ bash install.sh
```

### tools
- [fzf](https://marslo.github.io/ibook/devops/awesomeShell.html#fzf)
- [fd](https://marslo.github.io/ibook/devops/awesomeShell.html#fd)
- [rg](https://marslo.github.io/ibook/devops/awesomeShell.html#rg-the-faster-mg)
- [ag](https://marslo.github.io/ibook/devops/awesomeShell.html#ag-the-faster-mg)
- [fzy](https://marslo.github.io/ibook/devops/awesomeShell.html#fzy)
- [bat](https://marslo.github.io/ibook/devops/awesomeShell.html#bat)
- [c](https://marslo.github.io/ibook/devops/awesomeShell.html#c-bash-color)
- [devenv setup](https://marslo.github.io/ibook/linux/devenv.html)

## folder structure
```bash
dotfils                    # -> $HOME
├── .config
│   ├── nvim               # nvim/init.lua
│   └── ...
├── .marslo
│   ├── .alias             # all alias
│   ├── bin                # all bins/scripts
│   └── vimrc.d            # all vimrc congiures
├── .vimrc                 # source vimrc.d/*
├── .marsorc               # ╮ source all in `.marslo/{.alias,bin}`
├── .marsorc.wsl           # ╯
├── .bashrc                # source ~/.marslorc or ~/.marslorc.wsl
└── ...                    # rc/profile/ignore/...
```

![bash](https://github.com/marslo/dotfiles/raw/assets/screenshots/shell.png)

## manual configure
### `~/.marslo/.marslorc`
- add `source` as blow in `.bashrc` or `/etc/bashrc`(RHEL/CentOS) or `/etc/bash.bashrc`(Ubuntu) or `~/.bash_profile`(OSX)
  ```bash
  [ -f "~/.marslo/.marslorc" ] && source "~/.marslo/.marslorc"

  # wsl
  [ -f "~/.marslo/.marslorc.wsl" ] && source "~/.marslo/.marslorc.wsl"
  ```

### inputrc:
- Copy the `.inputrc` to `$HOME`
  ```bash
  $ cp ./dotfils/.inputrc ~/.inputrc
  ```

![hybird mode for inputrc](https://marslo.github.io/ibook/screenshot/shell/bash-bind-mode-string-cursor-shape.gif)

### nvim

  ![nvim](https://marslo.github.io/ibook/screenshot/vim/nvim-treesitter-coc-lspconfig.gif)

  ![nvim](https://github.com/marslo/dotfiles/raw/assets/screenshots/nvim.png)

### gitalias
```bash
$ cp ./dotfils/.marslo/.gitalias ~/.marslo

# included in .gitconfig
$ echo "[include]"                    >> ~/.gitconfig
$ echo "  path = ~/.marslo/.gitalias" >> ~/.gitconfig
# or
$ cat >> ~/.gitconfig << EOF
[include]
  path = ~/.marslo/.gitalias
EOF
```

![gitalias](https://github.com/marslo/dotfiles/raw/assets/screenshots/gitalias.gif)

### tig
#### installation
```bash
# ubuntu:
$ sudo apt install tig

# from source
$ git clone git@github.com:jonas/tig.git
$ make prefix=/usr/local/tig
$ sudo make prefix=/usr/local/tig install
```

- config: copy `.tigrc` to `$HOME` folder
  ```bash
  $ cp ./dotfils/.tigrc ~
  ```

### python IDLE

![idle solarized dark](https://github.com/marslo/dotfiles/raw/assets/screenshots/idle-solarized-dark.png)

![idle gruvbox](https://github.com/marslo/dotfiles/raw/assets/screenshots/idle-gruvbox.png)
