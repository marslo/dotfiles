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

function bd() {
  USER='svc_appbld'
  DOMAIN='engba'
  TYPE='appbuilder'

  # shellcheck disable=SC2048
  args=$(getopt rcd $*)
  if test $? != 0
  then
    echo -e 'Usage: [-r[c[d]]] HostnumVMnum
    -r: root
    -c: cdc builder (engma.veritas.com)
    -d: dev builder (appreldev)
    '
  else
    set -- $args

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

    /usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/marslo/.marslo/Marslo/Tools/Softwares/sshkey/Marslo\@Appliance ${USER}@${TYPE}${HOST}-vm${VM}.${DOMAIN}.veritas.com
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

# vim:ts=2:sts=2:sw=2:et:ft=sh
