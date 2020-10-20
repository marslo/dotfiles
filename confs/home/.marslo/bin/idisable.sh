#!/bin/bash
# shellcheck disable=SC1090
# =============================================================================
#     FileName : idisable.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2012
#   LastChange : 2020-10-20 22:32:29
# =============================================================================

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

function ccker()
{
  pushd .
  cd "$HOME/myworks/appliance/automation/robot/branches/dev_main" || return
  python utility/checkers/CodeChecker.py --check_all
  popd
}

function getcomputerversion()
{
  sudo dmidecode | ${GREP} -i prod
}

function gradleClean(){
  set +H
  pushd . > /dev/null
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
  popd > /dev/null
}

function envUpdate() {
  for i in $(seq 1 9); do
    ssh slave0"${i}" "cd ~/env; git clean -dfx; git reset --hard; git pull --all";
  done
}

# vim: ts=2 sts=2 sw=2 et ft=Groovy
