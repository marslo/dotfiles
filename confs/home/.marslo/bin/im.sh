#!/bin/bash
# shellcheck disable=SC1078,SC1079
# =============================================================================
#     FileName : irt.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2012
#   LastChange : 2020-10-20 21:53:33
#         Desc : for artifactory
# =============================================================================

# marslo grep
function mg() {
  usage="""mg - marslo grep - combined find and grep to quick find keywords
  \nSYNOPSIS
  \t$(c sY)\$ mg [i] [f] [m] [w] [a <num>] [b <num>] [c <num>] KEYWORD [<PATHA>]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ mg 'hello'
  \t\$ mg i 'hello' ~/.marslo
  \t\$ mg ic 3 'hello' ~/.marslo$(c)
  \nOPT:
  \n\t$(c B)i$(c) : ignore case
  \t$(c B)f$(c) : find file name only
  \t$(c B)m$(c) : find markdown only
  \t$(c B)w$(c) : match word only
  \t$(c B)a <num>$(c) : print <num> lines of trailing context after matching lines
  \t$(c B)b <num>$(c) : print <num> lines of leading context before matching lines
  \t$(c B)c <num>$(c) : print <num> lines of output context
  """
  kw=''
  p='.'
  opt='--color=always -n -H -E'
  name=''

  if [ 0 -eq $# ]; then
    echo -e "${usage}"
  else
    case $1 in
      [wW] | [iI] )
        opt="${opt} -$( echo $1 | tr '[:upper:]' '[:lower:]' )"
        [ 2 -le $# ] && kw="$2"
        [ 3 -eq $# ] && p="$3"
        ;;
      [fF] )
        opt="${opt} -l"
        [ 2 -le $# ] && kw="$2"
        [ 3 -eq $# ] && p="$3"
        ;;
      [mM] )
        name='-iname *.md'
        [ 2 -le $# ] && kw="$2"
        [ 3 -eq $# ] && p="$3"
        ;;
      [iI][fF] | [fF][iI] )
        opt="${opt} -i -l"
        [ 2 -le $# ] && kw="$2"
        [ 3 -eq $# ] && p="$3"
        ;;
      [iI][wW] | [wW][iI] )
        opt="${opt} -i -w"
        [ 2 -le $# ] && kw="$2"
        [ 3 -eq $# ] && p="$3"
        ;;
      [fF][wW] | [wW][fF] )
        opt="${opt} -l -w"
        [ 2 -le $# ] && kw="$2"
        [ 3 -eq $# ] && p="$3"
        ;;
      [iI][fF][wW] | [iI][wW][fF] | [fF][iI][wW] | [fF][wW][iI] | [wW][iI][fF] | [wW][fF][iI] )
        opt="${opt} -i -w -l"
        [ 2 -le $# ] && kw="$2"
        [ 3 -eq $# ] && p="$3"
        ;;
      [aA] | [bB] | [cC] | [iI][aA] | [iI][bB] | [iI][cC] | [aA][iI] | [bB][iI] | [cC][iI] )
        # line = -A $2 | -B $2 | -C $2
        line="-$( echo $1 | awk -F'[iI]' '{print $1,$2}' | sed -e 's/^[[:space:]]*//' | tr '[:lower:]' '[:upper:]' ) $2"
        opt="${opt} -i ${line}"
        [ 3 -le $# ] && kw="$3"
        [ 4 -eq $# ] && p="$4"
        ;;
      * )
        kw="$1"
        [ 2 -le $# ] && p="$2"
        ;;
    esac

    if [ -n "${kw}" ]; then
      # or using + instead of ; details: https://unix.stackexchange.com/a/43743/29178
      # shellcheck disable=SC2027,SC2125
      cmd="""find "${p}" -type f ${name} -not -path \"*git/*\" -not -path \"*node_modules/*\" -exec ${GREP} ${opt} "${kw}" {} \\;"""
      find "${p}" -type f ${name} \( -not -path "*git/*" -not -path "*node_modules/*" \) -exec ${GREP} ${opt} "${kw}" {} \; \
        || echo -e """\n$(c Y)ERROR ON COMMAND:$(c)\n\t$(c R)$ ${cmd}$(c) """
    else
      echo -e "${usage}"
    fi
  fi
}

# find file
function ff() {
  usage="""SYNOPSIS
  \n\t$(c sY)\$ ff <FILENAME> [<PATH>]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ ff myfile.txt
  \t\$ ff myfile.txt ~/.marslo$(c)
  """

  if [ 0 -eq $# ]; then
    echo -e "${usage}"
  else
    p='.'
    [ 2 -eq $# ] && p="$2"
    find "${p}" -type f -not -path "\'*git/*\'" -iname "*${1}*"
  fi
}

# marslo sed
function ms() {
  usage="""msed - marslo sed - sed all key words in the path
  \n$(c s)SYNOPSIS$(c)
  \n\t$(c sY)\$ msed [OPT] <ORIGIN_STRING> <NEW_STRING> [PATH]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ msed mystr MY_STR
  \t$(c G)\$ msed re '^.*\(.*\).*$' 'MY_STR'
  \t\$ msed mystr MY_STR ~/.marslo$(c)
  \nOPT:
  \n\t$(c B)r$(c) : use extended regular expressions in the script
  \t$(c B)e$(c) : add the script to the commands to be executed
  """

  p='.'
  sw=''     # source word
  tw=''     # target word
  opt='-i'

  if [ 2 -le $# ]; then
    case $1 in
      [rR] )
        opt="${opt} -r"
        [ 3 -le $# ] && sw="$2" && tw="$3"
        [ 4 -eq $# ] && p="$4"
        ;;
      [rR][eE] | [eE][rR] )
        opt="${opt} -r -e"
        [ 3 -le $# ] && sw="$2" && tw="$3"
        [ 4 -eq $# ] && p="$4"
        ;;
      * )
        [ 2 -le $# ] && sw="$1" && tw="$2"
        [ 3 -le $# ] && p="$3"
        ;;
    esac
  fi

  if [ -n "${sw}" ] && [ -n "${tw}" ]; then
    # shellcheck disable=SC2125,SC2027
    cmd="""find "${p}" -type f -not -path "*git/*" -exec sed ${opt} "s:${sw}:${tw}:g" {} ;"""
    ${cmd} \
      || echo -e """\n$(c Y)ERROR ON COMMAND:$(c)\n\t$(c R)$ ${cmd}$(c) """
  else
    echo -e "${usage}"
  fi
}

function mrc()
{
  source "${iRCHOME}/.marslorc"
}

function erc()
{
  /usr/local/bin/vim "${iRCHOME}/.marslorc"
}

# proxy clear
function pclr(){
  PROXY_ENV="http_proxy ftp_proxy https_proxy all_proxy socks_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY SOCKS_PROXY"
  for envvar in $PROXY_ENV; do
    unset "$envvar"
  done
  echo -e "$(c sM)all proxy environment variable has been removed.$(c)"
}

# proxy setup
function pset(){
  # myproxy=$(echo $1 | sed -n 's/\([0-9]\{1,3\}.\)\{4\}:\([0-9]\+\)/&/p')
  if [ 0 -eq $# ]; then
    myproxy='http://127.0.0.1:1087'
  else
    myproxy=$*
  fi
  # PROXY_ENV="http_proxy ftp_proxy https_proxy all_proxy socks_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY SOCKS_PROXY"
  PROXY_ENV='http_proxy ftp_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY'
  for envvar in $PROXY_ENV; do
    export "$envvar"="$myproxy"
  done
  echo -e "$(c sG)proxy has been all set as $myproxy.$(c)"
}

function color() {
  # https://unix.stackexchange.com/a/269085/29178
  for c; do
      printf '\e[48;5;%dm%03d' $c $c
  done
  printf '\e[0m \n'
}

function run() {
  usage="""run - shortcut to run particular commands
  \nSYNOPSIS
  \t$(c sY)\$ run <command>$(c)
  \nEXAMPLE
  \n\t$(c G)\$ run jenkins$(c)
  \nOPT:
  \n\t$(c B)jenkins$(c) : start jenkins service via docker
  """

  if [ 0 -eq $# ]; then
    echo -e "${usage}"
  else
    case $1 in
      jenkins )
        startDocker
        startJenkins
        ;;
      docker )
        startDocker
        ;;
      * )
        echo -e "${usage}"
        ;;
    esac
  fi
}

function startDocker() {
  if [ -z "$(ps aux | grep '/Applications/Docker.app/Contents/MacOS/Docker' | grep -v grep)" ]; then
    echo -e "$(c sY)~~> start Docker.app...$(c)"
    open -g -a Docker.app || exit

    i=0
    while ! docker system info &>/dev/null; do
      (( i++ == 0 )) && printf $(c sY)%-6s$(c) '    waiting for Docker to finish starting up...' || printf $(c sY)%s$(c) '.'
      sleep 1
    done
    (( i )) && printf '\n'
    echo -e "$(c sY)~~> Docker is ready...$(c)"
  else
    echo -e "$(c sG)~~> Docker is running, no need start docker process...$(c)"
  fi
}

function stopDocker() {
  if [ ! -z "$(ps aux | grep '/Applications/Docker.app/Contents/MacOS/Docker' | grep -v grep)" ]; then
    echo -e "$(c sM)~~> Quitting Docker.app...$(c)"
    osascript - << EOF || exit
    tell application "Docker"
      if it is running then quit it
    end tell
EOF
  else
    echo -e "$(c sB)~~> no need quit Docker.app since docker process isn't running...$(c)"
  fi
}

function startJenkins() {
  docker run \
         --name jenkins \
         --detach   \
         --rm \
         --network jenkins \
         --env DOCKER_HOST=tcp://docker:2376   \
         --env DOCKER_CERT_PATH=/certs/client \
         --env DOCKER_TLS_VERIFY=1   \
         --publish 80:8080 \
         --publish 50000:50000   \
         --env JENKINS_ADMIN_ID=admin \
         --env JENKINS_ADMIN_PW=admin \
         --env JAVA_OPTS=" \
                -DsessionTimeout=1440 \
                -DsessionEviction=43200 \
                -Djava.awt.headless=true \
                -Djenkins.ui.refresh=true \
                -Divy.message.logger.level=4 \
                -Dhudson.Main.development=true \
                -Duser.timezone='Asia/Chongqing' \
                -Djenkins.install.runSetupWizard=true \
                -Dpermissive-script-security.enabled=true  \
                -Djenkins.slaves.NioChannelSelector.disabled=true \
                -Djenkins.slaves.JnlpSlaveAgentProtocol3.enabled=false \
                -Dhudson.model.ParametersAction.keepUndefinedParameters=true \
                -Djenkins.security.ClassFilterImpl.SUPPRESS_WHITELIST=true \
                -Dhudson.security.ArtifactsPermission=true \
                -Dhudson.security.LDAPSecurityRealm.groupSearch=true \
                -Dhudson.security.csrf.DefaultCrumbIssuer.EXCLUDE_SESSION_ID=true \
                -Dcom.cloudbees.workflow.rest.external.ChangeSetExt.resolveCommitAuthors=true \
                -Dhudson.plugins.active_directory.ActiveDirectorySecurityRealm.forceLdaps=false \
                -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-same-origin allow-scripts; default-src 'self'; script-src * 'unsafe-eval'; img-src *; style-src * 'unsafe-inline'; font-src *;\" \
              " \
         --env JNLP_PROTOCOL_OPTS="-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=false" \
         --volume /opt/JENKINS_HOME:/var/jenkins_home \
         --volume /var/run/docker.sock:/var/run/docker.sock \
         jenkins/jenkins:latest

# -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true \
}

# vim: ts=2 sts=2 sw=2 et ft=Groovy
