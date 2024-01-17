Life is short, make it easier!
==========

## version
- Author: marslo
- Email: marslo.jiao@gmail.com
- Created: 2013-10-07 21:43:42
- LastChange: 2024-01-17 01:19:06

## content
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [setup](#setup)
- [`~/.marslo/.marslorc`](#marslomarslorc)
- [gitalias](#gitalias)
- [tig](#tig)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![ffunc.sh](./screenshot/ffunc.sh.gif)

![LS_COLORS](./screenshot/LS_COLORS.png)

### setup
```bash
$ bash run.sh
```

![bash](./screenshot/shell.png)

### `~/.marslo/.marslorc`
- add `source` as blow in `.bashrc` or `/etc/bashrc`(RHEL/CentOS) or `/etc/bash.bashrc`(Ubuntu) or `~/.bash_profile`(OSX)
  ```bash
  [ -f "~/.marslo/.marslorc" ] && source "~/.marslo/.marslorc"

  # wsl
  [ -f "~/.marslo/.marslorc.wsl" ] && source "~/.marslo/.marslorc.wsl"
  ```

- inputrc:
  - Copy the `.inputrc` to `$HOME`
    ```bash
    $ cp mylinux/confs/home/inputrc/.inputrc_bash ~/.inputrc
    ```

  ![hybird mode for inputrc](https://marslo.github.io/ibook/screenshot/shell/bash-bind-mode-string-cursor-shape.gif)

- the vim in github:

  ![nvim](https://marslo.github.io/ibook/screenshot/vim/nvim-treesitter-coc-lspconfig.gif)

  ![nvim](./screenshot/nvim.png)

### gitalias
- add `include` tag into `~/.gitconfig`
  ```
  [include]
    path = ~/.marslo/.gitalias
  ```

  ![gitalias](./screenshot/gitalias.gif)

### tig
#### installation
- ubuntu:
  ```bash
  $ sudo apt install tig
  ```
  - install
    ```bash
    $ git clone git@github.com:jonas/tig.git
    $ make prefix=/usr/local/tig
    $ sudo make prefix=/usr/local/tig install
    ```

- config: copy `.tigrc` to `$HOME` folder
  ```bash
  $ cp ./dotfils/.tigrc ~
  ```

### idle

![idle solarized dark](./screenshot/idle-solarized-dark.png)

![idle gruvbox](./screenshot/idle-gruvbox.png)
