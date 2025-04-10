#!/usr/bin/env bash

# credit: [ppo/bash-colors v3.0](https://github.com/ppo/bash-colors/blob/master/bash-colors.sh)
# author: @ppo

#  ┌───────┬────────────────┬─────────────────┐   ┌───────┬─────────────────┬───────┐
#  │ FG/BG │ COLOR          │ OCTAL           │   │ CODE  │ STYLE           │ OCTAL │
#  ├───────┼────────────────┼─────────────────┤   ├───────┼─────────────────┼───────┤
#  │  K/k  │ Black          │ \e[ + 3/4  + 0m │   │  s/S  │ Bold (strong)   │ \e[1m │
#  │  R/r  │ Red            │ \e[ + 3/4  + 1m │   │  d/D  │ Dim             │ \e[2m │
#  │  G/g  │ Green          │ \e[ + 3/4  + 2m │   │  i/I  │ Italic          │ \e[3m │
#  │  Y/y  │ Yellow         │ \e[ + 3/4  + 3m │   │  u/U  │ Underline       │ \e[4m │
#  │  B/b  │ Blue           │ \e[ + 3/4  + 4m │   │  f/F  │ Blink (flash)   │ \e[5m │
#  │  M/m  │ Magenta        │ \e[ + 3/4  + 5m │   │  n/N  │ Negative        │ \e[7m │
#  │  C/c  │ Cyan           │ \e[ + 3/4  + 6m │   │  h/H  │ Hidden          │ \e[8m │
#  │  W/w  │ White          │ \e[ + 3/4  + 7m │   │  t/T  │ Strikethrough   │ \e[9m │
#  ├───────┴────────────────┴─────────────────┤   ├───────┼─────────────────┼───────┤
#  │  High intensity        │ \e[ + 9/10 + *m │   │   0   │ Reset           │ \e[0m │
#  └────────────────────────┴─────────────────┘   └───────┴─────────────────┴───────┘
#                                                  Uppercase = Reset a style: \e[2*m

# shellcheck disable=SC2015,SC2059
c() { [ $# == 0 ] && printf "\e[0m" || printf "$1" | sed 's/\(.\)/\1;/g;s/\([SDIUFNHT]\)/2\1/g;s/\([KRGYBMCW]\)/3\1/g;s/\([krgybmcw]\)/4\1/g;y/SDIUFNHTsdiufnhtKRGYBMCWkrgybmcw/12345789123457890123456701234567/;s/^\(.*\);$/\\e[\1m/g'; }
# shellcheck disable=SC2086
cecho() { echo -e "$(c $1)${2}\e[0m"; }

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
