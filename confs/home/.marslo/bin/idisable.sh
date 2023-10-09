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
