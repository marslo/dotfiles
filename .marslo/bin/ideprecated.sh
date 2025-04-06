#!/bin/bash
# shellcheck disable=SC1090
# =============================================================================
#     FileName : idisable.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2012
#   LastChange : 2020-10-20 22:32:29
# =============================================================================

# get computer  version
function getcv() { sudo dmidecode | ${GREP} -i prod; }
function envUpdate() { for i in $(seq 1 9); do ssh slave0"${i}" "cd ~/env; git clean -dfx; git reset --hard; git pull --all"; done; }
function cdls() { cd "$1" && ls; }
function cdla() { cd "$1" && la; }
function chmv() { sudo mv "$1" "$2"; sudo chown -R "$(whoami)":"$(whoami)" "$2"; }
function chcp() { sudo cp -r "$1" "$2"; sudo chown -R "$(whoami)":"$(whoami)" "$2"; }
function cha() { sudo chown -R "$(whoami)":"$(whoami)" "$1"; }
function dir755() { find . -type d -perm 0777 \( -not -path "*.git" -a -not -path "*.git/*" \) -exec sudo chmod 755 {} \; -print ; }
function file644() { find . -type f -perm 0777 \( -not -path "*.git" -a -not -path "*.git/*" \) -exec sudo chmod 644 {} \; -print; }
function cleanview() { rm -rf ~/.vim/view/*; }
function zh() { zipinfo "$1" | head; }

# export cl=`p4 change -o | sed 's/<enter description here>/"Change list description"/' | sed '/^#/d' | sed '/^$/d' | p4 change -i | cut -d ' ' -f 2`
function p4nc() { p4 change -o | sed '/^#/d' | sed '/^$/d' | sed "s|Description: |Description: $*|" | sed "s|JIRA ID.*$|JIRA ID: APPSOL-00000|" | sed "s|Review.*$|Review: self-review|" | sed "s/+$//" | p4 change -i; }
function p4blame() { FILE="$1"; LINE="$2"; p4 annotate -cq "${FILE}" | sed "${LINE}q;d" | cut -f1 -d: | xargs p4 describe -s | sed -e '/Affected files/,$d'; }
function p4cd() { unset P4DIFF; p4 opened -c $1 | awk -F' ' '{print $1}' | p4 -x - -z tag diff -du > $1.diff; export P4DIFF=vimdiff; }

function dir() {
  [[ 0 -eq $# ]] && _p='.' || _p="$*"
  find . -iname "${_p}" -print0 | xargs -r0 ${LS} -altr | awk '{print; total += $5}; END {print "total size: ", total}';
}

function dir-h() {
  [[ 0 -eq $# ]] && _p='.' || _p="$*"
  find . -iname "${_p}" -exec ${LS} -lthrNF --color=always {} \;
  find . -iname "${_p}" -print0 | xargs -r0 du -csh| tail -n 1
}

function bd() {
  USER='svc_appbld'
  DOMAIN='engba'
  TYPE='appbuilder'

  # shellcheck disable=SC2048,SC2086
  args=$(getopt rcd $*)
  if test $? != 0
  then
    echo -e 'Usage: [-r[c[d]]] HostnumVMnum
    -r: root
    -c: cdc builder (engma.veritas.com)
    -d: dev builder (appreldev)
    '
  else
    set -- "${args}"

    for opt; do
      case ${opt} in
        -r) USER='root' ;;
        -c) DOMAIN='engma' ;;
        -d) TYPE='appreldev' ;;
      esac
    done

    for VAR in "$@"; do true; done
    HOST=${VAR:0:2}
    VM=${VAR:2}

    /usr/bin/ssh -o StrictHostKeyChecking=no \
                 -o UserKnownHostsFile=/dev/null \
                 -i /home/marslo/.marslo/Marslo/Tools/Softwares/sshkey/Marslo\@Appliance  \
                 "${USER}@${TYPE}${HOST}-vm${VM}.${DOMAIN}".veritas.com
  fi
}

function rcsync() {
  SITE="Jira Confluence Jenkins Gitlab Artifactory Sonar Slave"
  HNAME=$( hostname | tr '[:upper:]' '[:lower:]' )
  for i in $SITE; do
    CURNAME=$( echo "$i" | tr '[:upper:]' '[:lower:]' )
    if [ "$HNAME" != "$CURNAME" ]; then
      echo ------------------- "$i" ---------------------;
      pushd "$PWD" || return
      cd "/home/appadmin" || return
      rsync \
        -avzrlpgoD \
        --exclude=Tools \
        --exclude=.vim/view \
        --exclude=.vim/vimsrc \
        --exclude=.vim/cache \
        --exclude=.vim/.netrwhist \
        --exclude=.ssh/known_hosts \
        -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ' \
        .marslo .vim .vimrc .inputrc .tmux.conf .pip appadmin@"$i":~/
      popd || return
    fi
  done
}

gtoc() {
  top=$(git rev-parse --show-toplevel)
  if [ 1 -eq $# ]; then
    case $1 in
      [mM] )
        top="${top}/docs"
        ;;
    esac
  fi
  xargs doctoc --github \
               --notitle \
               --maxlevel 3 >/dev/null \
         < <( fd . "${top}" --type f --extension md --exclude SUMMARY.md --exclude README.md )
}

# how may days == ddiff YYYY-MM-DD now
hmdays() {
  usage="""
    SYNOPSIS
    \n\t\$ hmdays YYYY-MM-DD
    \nEXAMPLE
    \n\t\$ hmdays 1987-03-08
  """

  if [ 1 -ne $# ]; then
    echo -e "${usage}"
  else
    if date +%s --date "$1" > /dev/null 2>&1; then
      echo $((($(date +%s)-$(date +%s --date "$1"))/(3600*24))) days
    else
      echo -e "${usage}"
    fi
  fi
}

# for git diff
# Inspired from http://stackoverflow.com/questions/8259851/using-git-diff-how-can-i-get-added-and-modified-lines-numbers
function diff-lines() {
  local path=
  local line=
  while read; do
    esc=$'\033'
    if [[ $REPLY =~ ---\ (a/)?.* ]]; then
      continue
    elif [[ $REPLY =~ \+\+\+\ (b/)?([^[:blank:]$esc]+).* ]]; then
      path=${BASH_REMATCH[2]}
    elif [[ $REPLY =~ @@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+)(,[0-9]+)?\ @@.* ]]; then
      line=${BASH_REMATCH[2]}
    elif [[ $REPLY =~ ^($esc\[[0-9;]+m)*([\ +-]) ]]; then
      echo "$path:$line:$REPLY"
      if [[ ${BASH_REMATCH[2]} != - ]]; then
        ((line++))
      fi
    fi
  done
}

# author: Duane Johnson
# email: duane.johnson@gmail.com
# date: 2008 Jun 12
# license: MIT
# Modified by marslo.vida@gmail.com
# date: 2013-10-15 17:54:58
# Based on discussion at http://kerneltrap.org/mailarchive/git/2007/11/12/406496
# For get git infor
function gitinfo() {
  # pushd . >/dev/null
  # Find base of git directory
  # while [ ! -d .git ] && [ ! `pwd` = "/" ]; do cd ..; done

  gittop=$(git rev-parse --show-toplevel 2>/dev/null)

  # Show various information about this git directory
  if [ ! -z "$gittop" ]; then
    echo "== Remote URL: "
    git remote -v
    echo

    echo "== Remote Branches: "
    git branch -r
    echo

    echo "== Local Branches:"
    git branch
    echo

    echo "== Configuration (.git/config)"
    cat ${gittop}/.git/config
    echo

    echo "== Most Recent Commit"
    git plog --max-count=3
    echo

    echo "Type 'git plog', 'git plogs' and 'git log' for more commits, or 'git show' for full commit details."
  else
    echo "Not a git repository."
  fi
  # popd >/dev/null
}

# For ssh agent
# start the ssh-agent
function start_agent {
  echo "Initializing new SSH agent..."
  # spawn ssh-agent
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo succeeded
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" > /dev/null
  /usr/bin/ssh-add
}

function ssh_agent() {
  if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    # pgrep -f ${SSH_AGENT_PID}
    # shellcheck disable=SC2009
    ps -ef | ${GREP} "${SSH_AGENT_PID}" | ${GREP} ssh-agent$ > /dev/null || {
    start_agent;
  }
  else
    start_agent;
  fi
}

function pydict() {
  currentDir=$(pwd)
  cd "$HOME/.vim/bundle/pydiction" || return
  python pydiction.py "$@"
  cd "$currentDir" || return
}

function ccker() {
  pushd .
  cd "$HOME/myworks/appliance/automation/robot/branches/dev_main" || return
  python utility/checkers/CodeChecker.py --check_all
  popd || true
}

function gradleClean(){
  set +H
  pushd . > /dev/null
  # shellcheck disable=SC2035
  for i in $(${LS} -1d */); do
    gradleRootDir="./"
    SUBDIR=${i%%/}
    echo -e "$(c B)=== ${SUBDIR} ===$(c)"
    if [ ! -e "${gradleRootDir}/build.gradle" ]; then
      gradleRootDir=$(find "${WORKSPACE}" -name "build.gradle" -printf "%h\\n" | awk '{print length()"\t"$0 | "sort -n"}' | cut -f2 - | head -1)
      echo "gradleRootDir is ${gradleRootDir}"
    fi
    gradle clean
    gitclean
  done
  popd >/dev/null || true
}

function proxydefault() {
  myssproxy="socks5://127.0.0.1:1880"
  myppproxy="http://127.0.0.1:8123"

  socks_proxy=${myssproxy}
  SOCKS_PROXY=${myssproxy}

  all_proxy=${myppproxy}
  ALL_PROXY=${myppproxy}

  http_proxy=${myppproxy}
  HTTP_PROXY=${myppproxy}
  https_proxy=${myppproxy}
  HTTPS_PROXY=${myppproxy}
  ftp_proxy=${myppproxy}
  FTP_PROXY=${myppproxy}

  # kubeIP=""
  flannelIP="$(echo 10.244.0.{0..255} | sed 's: :,:g')"
  privIP="$(echo 192.168.10.{0..255} | sed 's: :,:g')"
  compDomain=".cdi.philips.com,.philips.com,pww.*.cdi.philips.com,pww.artifactory.cdi.philips.com,healthyliving.cn-132.lan.philips.com,*.cn-132.lan.philips.com,pww.sonar.cdi.philips.com,pww.gitlab.cdi.philips.com,pww.slave01.cdi.philips.com,pww.confluence.cdi.philips.com,pww.jira.cdi.philips.com,bdhub.pic.philips.com,tfsemea1.ta.philips.com,pww.jenkins.cdi.philips.com,blackduck.philips.com,fortify.philips.com"
  no_proxy="localhost,127.0.0.1,127.0.1.1,130.147.182.57,192.168.10.235,172.17.0.1,10.244.0.0,10.244.0.1,${compDomain},${flannelIP},${privIP}"
  NO_PROXY=$no_proxy

  export socks_proxy SOCKS_PROXY all_proxy ALL_PROXY
  export http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy FTP_PROXY
  export no_proxy NO_PROXY
}

function gitFetch() {
  GITDIR=${1%%/}
  GITBRANCH=$2
  ISStashed=false
  pushd . > /dev/null
  cd "${GITDIR}"
  echo -e "\\033[34m=== ${GITDIR} ===\\033[0m"

  if git rev-parse --git-dir > /dev/null 2>&1; then
    utFiles=$(git ls-files --others --exclude-standard)
    mdFiles=$(git ls-files --modified)
    cBranch=$(git rev-parse --abbrev-ref HEAD)
    [[ -n "${utFiles}" ]] && echo -e "\\033[35mUNTRACKED FILES in ${cBranch}: ${utFiles}\\033[0m"

    if ! git branch -a | ${GREP} ${GITBRANCH} > /dev/null 2>&1; then
      GITBRANCH=master
    fi
    echo -e "\\033[33m-> ${GITBRANCH}\\033[0m"

    # checkout branch to $GITBRANCH
    if [[ ! "${cBranch}" = "${GITBRANCH}" ]]; then
      if [[ -n "${mdFiles}" ]]; then
        echo -e "\\033[31mGIT STASH: ${GITDIR} : ${cBranch} !!\\033[0m"
        git stash save "auto-stashed by gitFetch command"
        ISStashed=true
      fi
      git checkout "${GITBRANCH}"
    fi

    # remove the local branch if the branch has been deleted in remote
    if git remote prune origin --dry-run | ${GREP} prune; then
      prBranch=$(git remote prune origin --dry-run | ${GREP} prune | awk -F'origin/' '{print $NF}')
      if [ "${cBranch}" = "${prBranch}" ] && [ -z "${mdFiles}" ]; then
        echo -e "\\033[32mThe current branch ${cBranch} has been rmeoved in remote. And the current branch has no modified files!\\033[0m"
        ISStashed=false
      fi

      if git branch | ${GREP} "${prBranch}"; then
        echo -e "\\033[35mREMOVE LOCAL BRNACH ${prBranch}, due to ${prBranch} has been rmeoved in remote.\\033[0m"
        if ! git branch -D "${prBranch}"; then
          echo -e "\\033[32mWARNING: REMOVE LOCAL BRANCH ${prBranch} failed!!\\033[0m"
        fi
      fi
    fi

    # git fetchall on ${GITBRANCH}
    git remote prune origin
    git fetch origin --prune
    git fetch --all --force
    git merge --all --progress

    # restore the current working branch
    if ${ISStashed}; then
      git checkout "${cBranch}"
      git stash pop
      echo -e "\\033[35mGIT STASH POP: ${GITDIR} : ${cBranch}\\033[0m"
    fi
  else
    echo -e "\\033[33mNOT Git Repo!!\\033[0m"
  fi
  popd > /dev/null
}

function fetchdir() {
  myDir="$1"
  for i in $(${LS} -1d ${myDir%%/}/); do
    gitFetch "$i" "dev"
  done
}

function fetchall() {
  if [ 1 -eq $# ]; then
    brName=$1
  else
    brName="dev"
  fi
  # shellcheck disable=SC2035
  for i in $(${LS} -1d */); do
    gitFetch "$i" "$brName"
  done
}


# vim:ts=2:sts=2:sw=2:et:ft=sh:
