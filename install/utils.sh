#!/usr/bin/env bash

function isWSL()    { if uname -r | command grep --color=never -q -i 'microsoft'; then echo 1; fi; }
function isOSX()    { [[ 'Darwin' = $(uname) ]] && echo 1; }
function isLinux()  { [[ '1' != "$(isWSL)" ]] && [[ 'Linux' = $(uname) ]] && echo 1; }
function isRHEL()   { command -v lsb_release >/dev/null && [[ 'RedHatEnterprise' = "$(lsb_release -si)" ]] && echo '1'; }
function isCentOS() { command -v lsb_release >/dev/null && [[ 'CentOSStream'     = "$(lsb_release -si)" ]] && echo '1'; }
function isUbuntu() { command -v lsb_release >/dev/null && [[ 'Ubuntu'           = "$(lsb_release -si)" ]] && echo '1'; }

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=indent
