Life is short, make it easier!
==========

## version
- Author: Marslo
- Email: marslo.jiao@gmail.com
- Created: 2013-10-07 21:43:42
- LastChange: 2021-08-11 19:49:38

## content
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [configurations](#configurations)
- [settings](#settings)
- [build and install moc (music on console) by source code](#build-and-install-moc-music-on-console-by-source-code)
- [screenshot](#screenshot)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


> reference:
> - [Nam Huy Linux Blog](http://namhuy.net/1397/disable-bluetooth-ubuntu-xubuntu-linux-mint.html)
> - [Stackoverflow answers](http://askubuntu.com/questions/67758/how-can-i-deactivate-bluetooth-on-system-startup)

## configurations
### automatic setup
```bash
$ bash run.sh
```

### HOME config usage
- Add the following statement in `.bashrc` or `/etc/bashrc`(RHEL/CentOS) or `/etc/bash.bashrc`(Ubuntu) or `~/.bash_profile`(OSX)
  ```bash
  [ -f "/path/to/mylinux/confs/home/.marslo/.marslorc" ] && source "/path/to/mylinux/confs/home/.marslo/.marslorc"
  ```

- inputrc:
  - Copy the `.inputrc` to `$HOME`
    ```bash
    $ cp mylinux/confs/home/inputrc/.inputrc_bash ~/.inputrc
    ```

- the vim in github:
  ```bash
  $ git clone git@github.com:b4winckler/vim.git
  ```

### Git alias
- add `include` tag into `~/.gitconfig`
  ```
  [include]
    path = /path/to/mylinux/confs/home/.marslo/.gitalias
  ```

- And make sure the `.marslorc`(.marslo/.marslorc) file sourced in `.bashrc`. Otherwise, `$ git ldiff` and `$ git info` not available.

### tig
#### installation
- ubuntu:
  ```bash
  $ sudo apt install tig
  ```

- install via manual:
  - download at [jonas/tig](https://github.com/jonas/tig)
    ```bash
    $ git clone git@github.com:jonas/tig.git
    ```
  - build and install
    ```bash
    $ make prefix=/usr/local/tig
    $ sudo make prefix=/usr/local/tig install
    ```

#### configuration
- copy `.tigrc` to `$HOME` folder
  ```bash
  $ cp mylinux/confs/home/tig/.tigrc ~
  ```

### konsole
#### installation
```bash
$ sudo apt install konsole
```

#### restore the settings
- copy `mylinux/confs/home/konsole` to `~/.kde/share/apps/konsole`
  ```bash
  $ cp -r mylinux/confs/home/konsole/ ~/.kde/share/apps/konsole
  ```

#### shortcuts in Konsole
- <kbd>Alt</kbd> + <kbd>J</kbd>: scroll down one line
- <kbd>Alt</kbd> + <kbd>K</kbd>: scroll up one line

### Gnome-Terminal
> - [inspired from askubuntu](http://askubuntu.com/questions/453906/how-to-disable-or-reorder-gnome-terminal-right-click-context-menu)

- move context menu items [_Open Terminal_, _Open Tab_, _Close window_]
  ```bash
  $ sudo cp mylinux/confs/terminal/usr/share/gnome-terminal/terminal.xml /usr/share/gnome-terminal/
  ```

## settings
### adjust Chinese font
- modified by manual
  ```bash
  $ cat /etc/fonts/conf.d/49-sansserif.conf
  ....
  18       <string>WenQuanYi Micro Hei</string>
  ....
  ```

- copy the template file to the `conf.d` folder
  ```bash
  $ sudo cp Configs/etc/fonts/49-sansserif.conf /etc/fonts/conf.d/
  ```

### install system monitor indicator

```bash
$ sudo add-apt-repository ppa:indicator-multiload/stable-daily
$ sudo apt update
$ sudo apt install indicator-multiload
```

### install ubuntu theme
- (nokto-theme) [Official Website](https://launchpad.net/~noobslab/+archive/ubuntu/themes?field.series_filter=trusty)
  ```bash
  $ sudo add-apt-repository ppa:noobslab/themes
  $ sudo apt update
  $ sudo apt install nokto-theme

  # OR:

  $ sudo cat >> /etc/apt/sources.list << EOF
  > deb http://ppa.launchpad.net/noobslab/themes/ubuntu trusty main
  > deb-src http://ppa.launchpad.net/noobslab/themes/ubuntu trusty main
  EOF

  $ sudo apt update
  ```

- ambiance-dark
  ```bash
  $ sudo add-apt-repository ppa:noobslab/themes
  $ sudo apt update
  $ sudo apt install ambiance-dark
  ```

### specified cursor
```bash
$ cat /usr/share/icons/default/index.theme
[Icon Theme]
Inherits=handhelds
```

### specified font for tty1-6
```bash
$ sudo dpkg-reconfigure console-setup
```

- `UTF-8` -> `Combined - Latin: Cyrillic: Greek` -> `Terminus` -> `24x12`
- `UTF-8` -> `Combined - Latin: Cyrillic: Greek` -> `TerminusBold` -> `24x12`

### specified size and scroolback for TTY 1-6

```bash
$ sudo mv /etc/default/grub.cfg{,_bak}
$ sudo cp Configs/Grub/etc/default/grub /etc/default
$ sudo update-grub && sudo reboot
```

### disable bluetooth booting
#### to stop bluetooth service

```bash
$ sudo service bluetooth stop
```

#### disable bluetooth service on startup

```bash
$ cat /etc/rc.local
....
# Turn off bluetooth
rfkill block bluetooth
exit 0
```

#### disable the bluetooth driver on startup

```bash
$ cat /etc/modprob.d/blacklist.conf
....
# Turn off bluetooth
blacklist btusb
```

#### cut power source for bluetooth to run

```bash
$ cat /etc/bluetooth/main.conf
...
4 DisablePlugins = network,input
...
37 nitiallyPowered = false
```

#### [DANGEROUS]: REMOVE BLUETOOTH MANAGER AND ALL DEPENDENCIES

```bash
$ sudo apt remove bluez* bluetooth
$ sudo apt autoremove
```

### ALSA Settings:
#### Informations
- Check the **type** of Sound Card:

    ```bash
    $ head -1 /proc/asound/card0/codec#0
    Realtek ALC262
    ```
- Check the **version** of Sound Card:

    ```bash
    $ /proc/asound/version
    Advanced Linux Sound Archite chue Driver Version 1.0.24
    ```
- Check the **configuration** about Sound Card

    ```bash
    $ vim /etc/modprobe.d/alsa-base.conf
    ```
#### Install extra libs (ubuntu 13.04)

```bash
$ sudo apt install build-essential ncurses-dev gettext libncursesw5-dev
$ sudo apt install xmlto
```

#### Update ALSA in Ubuntu (<= 12.10)
- Download **alsa driver**, **alsa lib** and **alsa utils**

    ```bash
    $ wget ftp://ftp.alsa-project.org/pub/driver/alsa-driver-1.0.25.tar.bz2
    $ wget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.25.tar.bz2
    $ wget ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.25.tar.bz2
    $ tar xjvf alsa-driver-1.0.25.tar.bz2
    $ tar xjvf alsa-lib-1.0.25.tar.bz2
    $ tar xjvf alsa-utils-1.0.25.tar.bz2
    ```

- Upgrade **alsa dirver**

    ```bash
    $ cd alsa-driver-1.0.25
    $ sudo ./configure
    $ sudo make
    $ sudo make install
    ```

- Upgrade **alsa lib**

    ```bash
    $ cd ../alsa-lib-1.0.25
    $ sudo ./configure
    $ sudo make
    $ sudo make install
    ```

- Upgrade **alsa utils**

    ```bash
    $ cd ../alsa-utils-1.0.25
    $ sudo ln -s libpanelw.so.5 /usr/lib/libpanelw.so
    $ sudo ln -s libformw.so.5 /usr/lib/libformw.so
    $ sudo ln -s libmenuw.so.5 /usr/lib/libmenuw.so
    $ sudo ln -s libncursesw.so.5 /lib/libncursesw.so
    $ ./configure --with-curses=ncurses
    $ sudo make
    $ sudo make install
    ```

- Reboot

    ```bash
    $ sudo shutdown -r now
    ```

#### Change settings in Sound Card
- Input `alsamixer`, and input <kbd>F6</kbd> to select sound card:

    ```bash
    $ alsamixer
    ```

![alsamixer](https://github.com/Marslo/LinuxStuff/blob/master/screenshot/alsamixer.png?raw=true)
- Startup Settings

    ```bash
    Name: [Everything_You_Want]
    Command: /sbin/alsactl restore
    ```

## build and install moc (music on console) by source code
### precondiction:
- download source code from [official web site](http://moc.daper.net/download)
- [moc-2.5.0-beta1](http://ftp.daper.net/pub/soft/moc/unstable/moc-2.5.0-beta1.tar.bz2)
- [DEB packages FTP](http://ftp.de.debian.org/pub/debian/pool/main/m/moc/)

### moc config:
- Check details at [marslo/moc-cmus](https://github.com/marslo/moc-cmus/blob/master/README.md)

### errors and solutions
- error: BerkeleyDB (libdb) not found
  ```bash
  $ sudo apt install libdb++-dev libdb-dev
  ```

- decoder.c:22:18: fatal error: ltdl.h
  ```bash
  $ sudo apt install libltdl-dev
  ```

- FATAL_ERROR: No valid sound driver!
  - Error shows:
    ```bash
    $ mocp
    Running the server...
    Trying OSS...
    FATAL_ERROR: No valid sound driver!
    FATAL_ERROR: Server exited!
    [marslo@iMarslo ~]

    $ gdb mocp core
    GNU gdb (GDB) 7.6.1-ubuntu
    Copyright (C) 2013 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
    and "show warranty" for details.
    This GDB was configured as "i686-linux-gnu".
    For bug reporting instructions, please see:
    <http://www.gnu.org/software/gdb/bugs/>...
    Reading symbols from /home/marslo/Tools/Software/SourceCode/Moc/moc-2.5.0-beta1/mocp...done.
    /home/marslo/Tools/Software/SourceCode/Moc/moc-2.5.0-beta1/core: No such file or directory.
    (gdb) run
    Starting program: /home/marslo/Tools/Software/SourceCode/Moc/moc-2.5.0-beta1/mocp
    [Thread debugging using libthread_db enabled]
    Using host libthread_db library "/lib/i386-linux-gnu/libthread_db.so.1".
    Running the server...
    Trying OSS...
    FATAL_ERROR: No valid sound driver!
    FATAL_ERROR: Server exited!
    [Inferior 1 (process 18165) exited with code 02]
    (gdb) exit
    Undefined command: "exit".  Try "help".
    (gdb) quit
    ```

  - soluction
      ```bash
      $ sudo apt install autoconf automake1.9 libasound2-dev libavcodec-dev libavformat-dev libcurl4-gnutls-dev libflac-dev libid3tag0-dev libltdl3-dev libmad0-dev libmodplug-dev libmpcdec-dev libncurses5-dev libncursesw5-dev libogg-dev libresid-builder-dev libsamplerate0-dev libsidplay2-dev libsidutils-dev libsndfile1-dev libspeex-dev libtagc0-dev libtool libvorbis-dev libwavpack-dev zlib1g-dev
      Reading package lists... Done
      Building dependency tree
      Reading state information... Done
      Note, selecting 'libltdl-dev' instead of 'libltdl3-dev'
      libltdl-dev is already the newest version.
      libncurses5-dev is already the newest version.
      libncursesw5-dev is already the newest version.
      libogg-dev is already the newest version.
      libogg-dev set to manually installed.
      libtool is already the newest version.
      libtool set to manually installed.
      libvorbis-dev is already the newest version.
      zlib1g-dev is already the newest version.
      libavcodec-dev is already the newest version.
      libavcodec-dev set to manually installed.
      libavformat-dev is already the newest version.
      The following packages were automatically installed and are no longer required:
      librcc0 librcd0 linux-headers-generic linux-image-generic
      Use 'apt autoremove' to remove them.
      The following extra packages will be installed:
      comerr-dev krb5-multidev libgssrpc4 libidn11-dev libkadm5clnt-mit8 libkadm5srv-mit8 libkdb5-6
      libkrb5-dev libldap2-dev librtmp-dev libsigsegv2 libtag1-dev m4
      Suggested packages:
      autoconf2.13 autoconf-archive gnu-standards autoconf-doc automake1.9-doc krb5-doc libasound2-doc
      libcurl4-doc libcurl3-dbg krb5-user
      Recommended packages:
      automake automaken
      The following NEW packages will be installed:
      autoconf automake1.9 comerr-dev krb5-multidev libasound2-dev libcurl4-gnutls-dev libflac-dev libgssrpc4
      libid3tag0-dev libidn11-dev libkadm5clnt-mit8 libkadm5srv-mit8 libkdb5-6 libkrb5-dev libldap2-dev
      libmad0-dev libmodplug-dev libmpcdec-dev libresid-builder-dev librtmp-dev libsamplerate0-dev
      libsidplay2-dev libsidutils-dev libsigsegv2 libsndfile1-dev libspeex-dev libtag1-dev libtagc0-dev
      libwavpack-dev m4
      0 upgraded, 30 newly installed, 0 to remove and 16 not upgraded.
      Need to get 6,250 kB of archives.
      After this operation, 16.9 MB of additional disk space will be used.
      ....
      ```

  - Check alas-base and alas-utils
    ```bash
    $ dpkg -l alsa-base
    Desired=Unknown/Install/Remove/Purge/Hold
    | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
    |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
    ||/ Name                 Version         Architecture    Description
    +++-====================-===============-===============-==============================================
    ii  alsa-base            1.0.25+dfsg-0ub all             ALSA driver configuration files

    $ dpkg -l alsa-utils
    Desired=Unknown/Install/Remove/Purge/Hold
    | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
    |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
    ||/ Name                 Version         Architecture    Description
    +++-====================-===============-===============-==============================================
    ii  alsa-utils           1.0.27.1-1ubunt i386            Utilities for configuring and using ALSA
    ```

## screenshot
### BASH
![BASH](https://github.com/Marslo/LinuxStuff/blob/master/screenshot/BASH_Screenshot.png?raw=true)

### MAN Page
![MAN_PAGE](https://github.com/Marslo/LinuxStuff/blob/master/screenshot/Colorful_ManPage_Screenshot.png?raw=true)

### tig
![tig](https://github.com/Marslo/LinuxStuff/blob/master/screenshot/tig.png?raw=true)

### configuring console-setup
![console-setup](https://github.com/Marslo/LinuxStuff/blob/master/screenshot/dpkg-reconfigure_console-setup.png?raw=true)
