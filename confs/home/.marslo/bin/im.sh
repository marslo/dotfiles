#!/usr/bin/env bash
# shellcheck disable=SC1078,SC1079,SC2076
# =============================================================================
#     FileName : im.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2012
#   LastChange : 2023-12-14 16:16:36
#         Desc : iMarslo
# =============================================================================

function exitOnError() { echo -e "$1"; }
function trim() { IFS='' read -r str; echo "${str}" | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//'; }
# shellcheck disable=SC2154,SC2086,SC1091
function mrc() { source "${iRCHOME}"/.marslorc; }
# https://serverfault.com/a/906310/129815
function ssl_expiry () { echo | openssl s_client -connect "${1}":443 2> /dev/null | openssl x509 -noout -enddate; }
function erc() { /usr/local/bin/vim "${iRCHOME}/.marslorc"; }
function kdev() { kubectl config use-context kubernetes-dev; }
function kprod() { kubectl config use-context kubernetes-prod; }
# shellcheck disable=SC2015
function kx() { [ "$1" ] && kubectl config use-context "$1" || kubectl config current-context ; }
function pipurl() { pip list --format=freeze | cut -d= -f1 | xargs pip show | awk '/^Name/{printf $2} /^Home-page/{print ": "$2}' | column -t; }
function getsum { awk '{ sum += $1 } END { print sum }' "$1"; }
## how many days since now https://tecadmin.net/calculate-difference-between-two-dates-in-bash/
function hmds() { echo $(( ( $(date -d "$1" +%s) - $(date +%s))/86400 )); }

function contains() {
  standard=$1
  sub=$2
  for _s in $(echo "${sub}" | fold -w1); do
    [[ ! "${standard}" =~ ${_s} ]] && return 1
  done
  return 0
}

# return 0 if found $2
function hasit() {
  standard=$1
  sub=$2
  result=1
  for _s in $(echo "${sub}" | fold -w1); do
    [[ "${standard}" =~ "${_s}" ]] && result=0
  done
  return ${result}
}

# marslo grep
function mg() {
  set -f
  usage="""\tmg - $(c B)M$(c)ARSLO $(c M)G$(c)REP - COMBINED FIND AND GREP TO QUICK FIND KEYWORDS
  \nSYNOPSIS
  \t$(c sY)\$ mg [i|I] [f|F] [m|M] [w|W]
  \t     [a|A <num>] [b|B <num>] [c|C <num>]
  \t     [e|E <suffix>]
  \t     KEYWORD [<PATHA>]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ mg 'hello'
  \t\$ mg i 'hello' ~/.marslo
  \t\$ mg iC 3 'hello' ~/.marslo$(c)
  \nOPT
  \t$(c B)i$(c)            : ignore case
  \t$(c B)f$(c)            : find file name only
  \t$(c B)m$(c)            : find markdown only
  \t$(c B)w$(c)            : match word only
  \t$(c B)a|A <num>$(c)    : print <num> lines of trailing context after matching lines
  \t$(c B)b|B <num>$(c)    : print <num> lines of leading context before matching lines
  \t$(c B)c|C <num>$(c)    : print <num> lines of output context
  \t$(c B)e|E <suffix>$(c) : [e]xclude <suffix> (filetype)
  """

  keyword=''
  path='.'
  debug=1
  grepOpt='--color=always -n -H'
  gitOptAdditional='-E'
  name=''
  param=$( tr '[:upper:]' '[:lower:]' <<< "$1" )

  contains 'ifmwabce' "${param}"
  # shellcheck disable=SC2034
  paramValid=$?

  if [[ 0 -eq $# ]] ; then
    echo -e "${usage}"
    return
  elif [[ 1 -eq $# ]]; then
    keyword="$1"
  elif [[ 2 -eq $# ]] && [[ "$2" =~ '/' || "$2" =~ '.' ]]; then
    keyword="$1"
    path="$2"
  else
    [[ "${param}" =~ 'i' ]] && grepOpt+=' -i'            && params='threeMost'
    [[ "${param}" =~ 'w' ]] && grepOpt+=' -w'            && params='threeMost'
    [[ "${param}" =~ 'f' ]] && grepOpt+=' -l'            && params='threeMost'
    [[ "${param}" =~ 'm' ]] && name='-iname *.md'        && params='threeMost'
    [[ "${param}" =~ 'd' ]] && debug=0                   && params='threeMost'
    [[ "$1" =~ 'a'       ]] && grepOpt+=" -i -A $2"      && params='fourMost'
    [[ "$1" =~ 'b'       ]] && grepOpt+=" -i -B $2"      && params='fourMost'
    [[ "$1" =~ 'c'       ]] && grepOpt+=" -i -C $2"      && params='fourMost'
    [[ "$1" =~ 'A'       ]] && grepOpt+=" -A $2"         && params='fourMost'
    [[ "$1" =~ 'B'       ]] && grepOpt+=" -B $2"         && params='fourMost'
    [[ "$1" =~ 'C'       ]] && grepOpt+=" -C $2"         && params='fourMost'
    [[ "${param}" =~ 'e' ]] && name='-not -iname *.'"$2" && params='fourMost'

    if [ 'threeMost' == "${params}" ]; then
      [[ 2 -le $# ]] && keyword="$2"
      [[ 3 -eq $# ]] && path="$3"
    elif [ 'fourMost' == "${params}" ]; then
      [[ 3 -le $# ]] && keyword="$3"
      [[ 4 -eq $# ]] && path="$4"
    fi

  fi

  if [ -n "${keyword}" ]; then

    # shellcheck disable=SC1003
    if ! hasit '\' "${keyword}"; then
      grepOpt+=" ${gitOptAdditional}"
    fi

    # or using + instead of ; details: https://unix.stackexchange.com/a/43743/29178
    # shellcheck disable=SC2027,SC2125
    cmd=" find '${path}'"
    cmd+=" -type f"
    cmd+=" ${name}"
    cmd+=" -not -path '*.git/*'"
    cmd+=" -not -path '*node_modules/*'"
    cmd+=" -exec ${GREP} ${grepOpt} '${keyword}' {} \;"

    # find "${path}" \
         # -type f \
         # ${name} \
         # -not -path '*git/*' \
         # -not -path '*node_modules/*' \
         # -exec ${GREP} ${grepOpt} "${keyword}" {} \; ||

    [[ 0 -eq debug ]] &&
        echo -e """
          $(c G)DEBUG INFO:$(c)
                 $(c Y)\$1$(c) : $(c C)'${1}'$(c)
                 $(c Y)\$2$(c) : $(c C)'${2:-}'$(c)
                 $(c Y)\$3$(c) : $(c C)'${3:-}'$(c)
                 $(c Y)\$4$(c) : $(c C)'${4:-}'$(c)
            $(c Y)keyword$(c) : $(c C)'${keyword}'$(c)
               $(c Y)path$(c) : $(c C)'${path:-}'$(c)
            $(c Y)grepOpt$(c) : $(c C)'${grepOpt}'$(c)
                $(c Y)cmd$(c) : $(c C)\$${cmd}$(c)
         """

    eval "${cmd}" ||
         echo -e """\n$(c Y)ERROR ON COMMAND:$(c)\n\t$(c R)$ ${cmd}$(c) """

  elif [ 0 -ne $# ]; then
    echo -e "${usage}"
  fi

  set +f
}

# [f]ind [f]ile and [s]ort
function ffs() {
  path=${1:-~/.marslo}
  num=${2:-10}
  depth=${3:-}
  option='-type f'
  [[ -n "${depth}" ]] && option="-maxdepth ${depth} ${option}"
  if [[ '-g' = "${path}" ]]; then
    # git show --name-only --pretty="format:" -"${num}" | awk 'NF' | sort -u
    # references: https://stackoverflow.com/a/54677384/2940319
    git log --date=iso-local --first-parent --pretty=%cd --name-status |
        awk 'NF==1{date=$1}NF>1 && !seen[$2]++{print date,$0}' FS=$'\t' |
        head -"${num}"
  elif [[ '-fg' = "${path}" ]]; then
    # references: https://stackoverflow.com/a/63864280/2940319
    git ls-tree -r --name-only HEAD -z |
        TZ=PDT xargs -0 -I_ git --no-pager log -1 --date=iso-local --format="%ad _" -- _ |
        sort -r |
        head -"${num}"
  else
    # shellcheck disable=SC2086
    find "${path}" ${option} \
                   -not -path '*/\.git/*' \
                   -not -path '*/node_modules/*' \
                   -not -path '*/go/pkg/*' \
                   -not -path '*/git/git*/*' \
                   -not -path '*/.marslo/utils/git/*' \
                   -printf "%10T+ | %p\n" |
    sort -r |
    head "-${num}"
  fi
}

# [f]ind [f]ile with [f]ind
function fff() {
  # shellcheck disable=SC1078,SC1079
  usage="""\t$(c B)f$(c)ind $(c M)f$(c)ile(s)
  \nSYNOPSIS
  \n\t$(c sY)\$ fff <FILENAME> [<PATH>]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ fff myfile.txt
  \t\$ ff myfile.txt ~/.marslo$(c)
  """

  if [ 0 -eq $# ]; then
    echo -e "${usage}"
  else
    path='.'
    [ 2 -eq $# ] && path="$2"
    find "${path}" -type f -not -path "\'*git/*\'" -iname "*${1}*"
  fi
}


# marslo sed
function ms() {
  # shellcheck disable=SC1078,SC1079
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

  path='.'
  sw=''     # source word
  tw=''     # target word
  opt=''

  if [ 2 -le $# ]; then
    case $1 in
      [rR] )
        opt="${opt} -r"
        [ 3 -le $# ] && sw="$2" && tw="$3"
        [ 4 -eq $# ] && path="$4"
        ;;
      [rR][eE] | [eE][rR] )
        opt="${opt} -r -e"
        [ 3 -le $# ] && sw="$2" && tw="$3"
        [ 4 -eq $# ] && path="$4"
        ;;
      * )
        [ 2 -le $# ] && sw="$1" && tw="$2"
        [ 3 -le $# ] && path="$3"
        ;;
    esac
  fi

  if [ -n "${sw}" ] && [ -n "${tw}" ]; then
    # shellcheck disable=SC2125,SC2027
    cmd="""find "${path}" -type f -not -path "*git/*" -exec sed ${opt} \"s:${sw}:${tw}:g\" -i {} \;"""
    eval "${cmd}" ||
         echo -e """\n$(c Y)ERROR ON COMMAND:$(c)\n\t$(c R)$ ${cmd}$(c) """
  else
    echo -e "${usage}"
  fi
}

# proxy clear
function pclr(){
  pEnv="http_proxy ftp_proxy https_proxy all_proxy socks_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY SOCKS_PROXY"
  for envvar in ${pEnv}; do
    unset "${envvar}"
  done
  echo -e "$(c sM)all proxy environment variable has been removed.$(c)"
}

# proxy setup
# myproxy=$(echo $1 | sed -n 's/\([0-9]\{1,3\}.\)\{4\}:\([0-9]\+\)/&/p')
function pset(){
  myproxy=$( [ 0 -eq $# ] && echo 'http://127.0.0.1:8081' || echo "$*" )
  pEnv='http_proxy ftp_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY'
  # pEnv+='socks_proxy SOCKS_PROXY'

  for envvar in $pEnv; do
    export "${envvar}"="${myproxy}"
  done
  echo -e "$(c sG)proxy has been all set as ${myproxy}.$(c)"
}

function run() {
  usage="""run - shortcut to run particular commands
  \nSYNOPSIS
  \t$(c sY)\$ run <command>$(c)
  \nEXAMPLE
  \t$(c G)\$ run jenkins$(c)
  \nOPT:
  \t$(c B)jenkins$(c) : start jenkins service via docker
  \t$(c B)iaws$(c) : enable route for jenkins instance in aws
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
      iaws )
        enableAWShost
        ;;
      * )
        echo -e "${usage}"
        ;;
    esac
  fi
}

function stop() {
  usage="""stop - shortcut to stop particular commands
  \nSYNOPSIS
  \t$(c sY)\$ stop <command>$(c)
  \nEXAMPLE
  \t$(c G)\$ stop jenkins$(c)
  \nOPT:
  \t$(c B)docker$(c)  : stop docker daemon
  \t$(c B)jenkins$(c) : stop jenkins service
  """

  if [ 0 -eq $# ]; then
    echo -e "${usage}"
  else
    case $1 in
      jenkins )
        docker stop jenkins
        echo -e "$(c sM)~~> stop jenkins service..$(c)"
        ;;
      docker )
        stopDocker
        ;;
      * )
        echo -e "${usage}"
        ;;
    esac
  fi
}

function startDocker() {
  if ! pgrep -f '/Applications/Docker.app/Contents/MacOS/Docker' >/dev/null 2>&1; then
    echo -e "$(c sY)~~> start Docker.app ...$(c)"

    i=0
    open -g -a Docker.app &&
    while ! docker system info &>/dev/null; do
      (( i++ == 0 )) && printf "$(c sY)%-6s$(c)     waiting for Docker to finish starting up..." || printf "$(c sY)%s$(c)."
      sleep 1
    done
    (( i )) && printf '\n'
    echo -e "$(c sY)~~> docker is ready...$(c)"
  else
    echo -e "$(c sG)~~> docker is running, no need start docker process ...$(c)"
  fi
}

function stopDocker() {
  if pgrep -f '/Applications/Docker.app/Contents/MacOS/Docker' >/dev/null 2>&1; then
    echo -e "$(c sM)~~> quitting Docker.app...$(c)"
    osascript - << EOF || exit
    tell application "Docker"
      if it is running then quit it
    end tell
EOF
  # or osascript -e 'quit app "Docker.app"' (https://forums.docker.com/t/restart-docker-from-command-line/9420/7)
  else
    echo -e "$(c sB)~~> no need quit Docker.app since docker process isn't running...$(c)"
  fi
}

#        --network jenkins \
#        --env DOCKER_HOST=tcp://docker:2376   \
#        --env DOCKER_CERT_PATH=/certs/client \
#        --env DOCKER_TLS_VERIFY=1   \
function startJenkins() {
  docker run \
         --name jenkins \
         --detach   \
         --rm \
         --publish 8080:8080 \
         --publish 50000:50000   \
         --env JENKINS_ADMIN_ID=admin \
         --env JENKINS_ADMIN_PW=admin \
         --env JAVA_OPTS=" \
                -XX:+UseG1GC \
                -Xms8G  \
                -Xmx16G \
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
                -Dhudson.model.ParametersAction.keepUndefinedParameters=true \
                -Dhudson.model.DirectoryBrowserSupport.CSP=\"\" \
                -Djsch.client_pubkey=\"ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,rsa-sha2-512,rsa-sha2-256,ssh-rsa\" \
                -Djsch.server_host_key=\"ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,rsa-sha2-512,rsa-sha2-256,ssh-rsa\"
              " \
         --env JNLP_PROTOCOL_OPTS="-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=false" \
         --volume /opt/JENKINS_HOME:/var/jenkins_home \
         --volume /var/run/docker.sock:/var/run/docker.sock \
         jenkins/jenkins:latest

        # -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true \
        # -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-same-origin allow-scripts; default-src 'self'; script-src * 'unsafe-eval'; img-src *; style-src * 'unsafe-inline'; font-src *;\" \
}

function enableAWShost() {
  sudo /sbin/route get 34.233.44.163
  sudo /sbin/route -nv add -host 34.233.44.163 172.16.0.1
  sudo /sbin/route -nv add -host 3.230.55.102 172.16.0.1
  sudo /sbin/route get 34.233.44.163
  sudo /sbin/route get 3.230.55.102
}

function trust() {
  host=$*
  sudo /sbin/route get "${host}"
  sudo /sbin/route -nv add -host "${host}" 172.16.0.1
  sudo /sbin/route get "${host}"
}

# [f]unction [c]ome [f]rom
function fcf() {
  if [[ 1 -ne $# ]] ; then
    echo 'Error : provide a function name'
  fi
  shopt -s extdebug; declare -F "$1"; shopt -u extdebug
}

# yum whatprovides
brew-whatprovides() {
  if [[ 0 -ne $# ]]; then
    _p="$*";
    # shellcheck disable=SC2086
    _realp="$(realpath ${_p})";
    while read -r pkg; do
      echo -ne "\r$(tput el)>> searching in ${pkg} ..."
      if brew list --verbose "${pkg}" 2>/dev/null | grep "${_realp}" >/dev/null 2>&1; then
        echo -ne "\r$(tput el)>> \033[0;32m${_p}\033[0m ( \033[0;37m${_realp}\033[0m ) provided by \033[0;33m${pkg}\033[0m";
        break;
      fi;
    done < <(brew leaves);
  fi
}

# vim:ts=2:sts=2:sw=2:et:ft=sh
