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
  - [dotfiles](#dotfiles)
  - [gh extensions](#gh-extensions)
  - [fonts](#fonts)
  - [tools](#tools)
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

![ffunc.sh](https://github.com/marslo/dotfiles/blob/assets/screenshots/ffunc.sh.new.gif)

![LS_COLORS](https://github.com/marslo/dotfiles/raw/assets/screenshots/LS_COLORS-2.png)

![LS_COLORS_ALL](https://github.com/marslo/dotfiles/raw/assets/screenshots/LS_COLORS_ALL-2.png)

## setup
### dotfiles
```bash
$ bash install.sh
```

### gh extensions
```bash
# gh new
$ gh extension install marslo/gh-new
$ gh new --setup --force

# gh ops
$ gh extension install marslo/gh-ops
$ gh ops --setup --force
```

### fonts

> [!TIP]
> - [installation guild for nerd fonts patched by v3.4.0.2](https://github.com/marslo/fonts/releases/tag/v3.4.0.2)

- [nice fonts](https://marslo.github.io/ibook/tools/fonts.html)
- [nerd-fonts](https://www.nerdfonts.com/) | [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
- [powerline/fonts](https://github.com/powerline/fonts)

```bash
# show fonts
$ fc-list | sed -re 's/^.+\/([^:]+):\s?([^,:]+),?:?.*$/\1 : \2/g' | column -t -s: -o: | sort -t':' -k2'

# show font properties
$ fc-query /path/to/font.ttf
## show font family only
$ fc-query -f '%{family}\n' /path/to/font.ttf
```

- RecMonoCasual Nerd Font Mono
  ```bash
  $ curl --create-dirs -O --output-dir "${fontsPath}" \
         -fsSL --remote-name-all \
         https://github.com/marslo/fonts/raw/fonts/Recursive/Recursive_Code_NF/RecMonoCasual/RecMonoCasualNerdFontMono-Regular.otf \
         https://github.com/marslo/fonts/raw/fonts/Recursive/Recursive_Code_NF/RecMonoCasual/RecMonoCasualNerdFontMono-Italic.otf \
         https://github.com/marslo/fonts/raw/fonts/Recursive/Recursive_Code_NF/RecMonoCasual/RecMonoCasualNerdFontMono-Bold.otf \
         https://github.com/marslo/fonts/raw/fonts/Recursive/Recursive_Code_NF/RecMonoCasual/RecMonoCasualNerdFontMono-BoldItalic.otf
  ```

- Monaco Nerd Font Mono
  ```bash
  # otf
  $ curl --create-dirs -O --output-dir "${fontsPath}" -fsSL \
         https://github.com/marslo/fonts/raw/fonts/Monaco/MonacoNerdFontMono-Regular.otf

  # ttf
  $ curl --create-dirs -O --output-dir "${fontsPath}" -fsSL \
         https://github.com/marslo/fonts/raw/fonts/Monaco/MonacoNerdFontMono-Regular.otf
  ```

- [more](https://github.com/marslo/fonts?tab=readme-ov-file#install-patched-fonts)

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
dotfiles                   # -> $HOME
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
  if uname -r | command grep --color=never -q -i 'microsoft';  then
    [ -f "~/.marslo/.marslorc.wsl" ] && source "~/.marslo/.marslorc.wsl"
  fi
  ```

### inputrc:
- copy the `.inputrc` to `$HOME`
  ```bash
  $ cp .inputrc ~/.inputrc
  ```

![hybrid mode for inputrc](https://marslo.github.io/ibook/screenshot/shell/bash-bind-mode-string-cursor-shape.gif)

### nvim

> [!TIP]
> - <kbd>Tab</kbd>: for copilot auto-completion
> - <kbd>Ctrl</kbd>+<kbd>j</kbd>: for coc-snippets
> - <kbd>Ctrl</kbd>+<kbd>m</kbd>: for lsp auto-completion

  ![nvim](https://github.com/marslo/ibook/raw/marslo/docs/screenshot/vim/nvim-coc-copilot-snippets.gif)

  ![nvim](https://github.com/marslo/dotfiles/raw/assets/screenshots/nvim-2.png)

### gitalias
```bash
$ cp .marslo/.gitalias ~/.marslo

# included in .gitconfig
$ echo "[include]"                               >> ~/.gitconfig
$ echo "  path = ~/.marslo/gitconfig.d/gitalias" >> ~/.gitconfig
# or
$ cat >> ~/.gitconfig << EOF
[include]
  path = ~/.marslo/gitconfig.d/gitalias
EOF
```

![gitalias](https://github.com/marslo/dotfiles/raw/assets/screenshots/gitalias.v2.gif)

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
  $ cp .tigrc ~
  ```

### python IDLE

- solarized dark

  ![idle solarized dark](https://github.com/marslo/dotfiles/raw/assets/screenshots/idle-solarized-dark.png)

- gruvbox

  ![idle gruvbox](https://github.com/marslo/dotfiles/raw/assets/screenshots/idle-gruvbox.png)

- tango

  ![idle gruvbox](https://github.com/marslo/dotfiles/raw/assets/screenshots/idle-tango.png)
