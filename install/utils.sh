#!/usr/bin/env bash

function isWSL()     { uname -r | command grep --color=never -q -i 'microsoft'; }
function isCygwin()  { test "$(uname -s)" =~ 'CYGWIN_NT'; }
function isGitBash() { test "$(uname -s)" =~ 'MINGW64_NT'; }
function isOSX()     { test 'Darwin' = "$(uname -s)"; }
function isLinux()   { ! isWSL && test 'Linux' = "$(uname -s)"; }
function isDebian()  { test -f /etc/os-release && grep -iqE 'ID_LIKE="?debian' /etc/os-release; }
function isFedora()  { test -f /etc/os-release && test 'fedora' = "$(awk -F '='    '/^ID=/ { print $2 }' /etc/os-release)"; }
function isUbuntu()  { test -f /etc/os-release && test 'ubuntu' = "$(awk -F '='    '/^ID=/ { print $2 }' /etc/os-release)"; }
function isRHEL()    { test -f /etc/os-release && test 'rhel'   = "$(awk -F '[="]' '/^ID=/ { print $3 }' /etc/os-release)"; }
function isCentOS()  { test -f /etc/os-release && test 'centos' = "$(awk -F '[="]' '/^ID=/ { print $3 }' /etc/os-release)"; }

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:foldmethod=indent
