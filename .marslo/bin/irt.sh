#!/usr/bin/env bash
# shellcheck disable=SC1078,SC1079
# =============================================================================
#  @Deprecated
#     FileName : irt.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2012
#   LastChange : 2026-02-17 20:05:31
# =============================================================================

RT_URL='https://my.artifactory.com/artifactory'
RT_PROJECT='project-1'
declare -a CURL_OPT=( -s -g --netrc-file "$HOME/.marslo/.netrc" )

function rtclean() {
  # shellcheck disable=SC2155
  local USAGE="""
  $(c sM)rtclean$(c) - artifactory clean - clean artifacts in Artifactory via repo and build info

  SYNOPSIS
    $(c sY)\$ rtclean [bi] [vwi] [repo] [build-id]$(c)

  EXAMPLE
    $(c G)\$ rtclean integration 1234$(c)
  """

  # shellcheck disable=SC2046
  if [ 2 -gt $# ]; then
    echo -e "${USAGE}"
  else
    case $1 in
      bi ) rtbdi "$(echo "${@: -$(( $#-1 ))}" | cut -d' ' -f1-)" ;;
       * ) rtdel "$(echo "$@" | cut -d' ' -f1-)"                 ;;
    esac
  fi
}

function rtsearch() {
  # shellcheck disable=SC2155
  local USAGE="""
  $(c sM)rtsearch$(c) - artifactory search - search artifacts and(or) build info in Artifactory via repo and condition

  SYNOPSIS
    $(c sY)\$ rtsearch [bi] [wvi] [repo] [condition] [name|info]$(c)
  OPTIONS
    $(c Y)bi$(c) search via property

  EXAMPLE
    $(c Wdi)# search sub-folder detail info in integration repo 10 days ago$(c)
    $(c G)\$ rtsearch integration 10days$(c)

    $(c Wdi)# search sub-folder name ONLY in integration repo 10 days ago$(c)
    $(c G)\$ rtsearch integration 10days name$(c)

    $(c Wdi)# search 1234(build number) in maven(reponame) build info$(c)
    $(c G)\$ rtsearch maven 1234 info$(c)

    $(c Wdi)# search artifacts built from Jenkins job '*marslo/sandbox*'$(c)
    $(c G)\$ rtsearch bi build.url '*marslo*sandbox*'$(c)
  """

  # shellcheck disable=SC2046
  if [ 2 -gt $# ]; then
    echo -e "${USAGE}"
  else
    case $1 in
      bi ) rtsp $(echo "${@: -$(( $#-1 ))}" | cut -d' ' -f1-) ;;
       * ) rtsc $(echo "$@" | cut -d' ' -f1-)                 ;;
    esac
  fi
}

# shellcheck disable=SC2155
function rtsp() {
  local USAGE="""
  $(c sM)rtsp$(c) - artifactory search with properties - search artifacts via properties

  SYNOPSIS
    $(c sY)\$ rtsp [wvi] [property name] [property value] [repo]$(c)

  EXAMPLE
    $(c Wdi)# search all artifacts built from Jenkins job '*marslo*sandbox*'$(c)
    $(c G)\$ rtsp build.url '*marslo*sandbox*'$(c)

    $(c Wdi)# search artifacts built from Jenkins job '*marslo*sandbox*' for project vega$(c)
    $(c G)\$ rtsp v build.url '*marslo*sandbox*'$(c)

    $(c Wdi)# search artifacts built from Jenkins job '*marslo*sandbox*' for project wukong and precommit stage$(c)
    $(c G)\$ rtsp w build.url '*marslo*sandbox* precommit'$(c)
  """

  local rtProj=''
  local repo=''
  local sedstr='^.*api/storage/([^/]+-local/([^/]+/){1}).*$'
  # shellcheck disable=SC2034
  local defaultRepos="project-precommit,$(echo project-{precommit,release,release-candidate} | tr ' ' ','),$(echo wukong-{precommit,postcommit,nightly,pre-release,post-release,integration} | tr ' ' ',')"

  if [ 2 -gt $# ]; then
    echo -e "${USAGE}"
  else
    case $1 in
      [wW] | [vV] | [iI] )
        p=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
        [ 'w' == "${p}" ] && rtProj='project-1'
        [ 'v' == "${p}" ] && rtProj='project-2'
        [ 'i' == "${p}" ] && rtProj='project-3'
        pName="$2"
        pValue="$3"
        [ 3 -eq $# ] && repo="&repos=$(echo ${rtProj}-{precommit,postcommit,nightly,pre-release,post-release,nightly,integration,release,release-candidate} | tr ' ', ',')"
        [ 4 -eq $# ] && repo="&repos=${rtProj}-$4"
        [ 5 -lt $# ] && echo -e "${USAGE}"
        ;;
      r )
        pName="$2"
        pValue="$3"
        [ 3 -eq $# ] && repo="&repos=$(echo {project-1,project-2}-{release-candidate,release} | tr ' ', ',')"
        sedstr='^.*api/storage/([^/]+-local/([^/]+/){2}).*$'
        ;;
      * )
        pName="$1"
        pValue="$2"
        [ 2 -eq $# ] && repo="&repos="                            # `repo=''` means search to all repos
        # [ 2 -eq $# ] && repo="&repos=${defaultRepos}"
        [ 3 -eq $# ] && repo="&repos=$(echo {project-1,project-2,project-3}-$3 | tr ' ', ',')"
        ;;
    esac

    echo -e """Artifactory search via Properties '${pName}=${pValue}':
      $(c Y)~~> api url: '${RT_URL}/api/search/prop?${pName}=${pValue}${repo}'$(c)
    """

    curl -sg -X GET \
         "${RT_URL}"/api/search/prop?"${pName}"="${pValue}${repo}" \
         | jq --raw-output .results[].uri \
         | sed -re "s:${sedstr}:\1:" \
         | uniq
  fi
}

function rtsc() {
  # shellcheck disable=SC2155
  local USAGE="""
  $(c sM)rtsc$(c) - artifactory search with conditional - search artifacts and(or) build info in Artifactory via repo and condition

  SYNOPSIS
    $(c sY)\$ rtsc [wvi] [repo] [condition] [name|info]$(c)

  EXAMPLE
    $(c Wdi)# search sub-folder detail info in integration repo 10 days ago$(c)
    $(c G)\$ rtsc integration 10days$(c)

    $(c Wdi)# search sub-folder name ONLY in integration repo 10 days ago$(c)
    $(c G)\$ rtsc integration 10days name$(c)

    $(c Wdi)# search 1234(build number) in maven(reponame) build info$(c)
    $(c G)\$ rtsc maven 1234 info$(c)
  """
  local rtProj="${RT_PROJECT}"
  local show=false
  local extra=''

  if [ 2 -gt $# ]; then
    echo -e "${USAGE}"
  else
    case $1 in
      [wW] | [vV] | [iI] )
        p=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
        [ 'w' == "${p}" ] && rtProj='project-1'
        [ 'v' == "${p}" ] && rtProj='project-2'
        [ 'i' == "${p}" ] && rtProj='project-3'
        rtName="$2"
        condition="$3"
        [ 4 -eq $# ] && show=$4
        ;;
      * )
        rtName="$1"
        condition="$2"
        [ 3 -eq $# ] && show=$3
        ;;
    esac

    repo="${rtProj}-${rtName}-local"
    builds="${rtProj} - ${rtName}"
    [ 'name' = "${show}" ] && extra='| jq --raw-output .results[].name?'

    echo -e """ Artifactory search via Conditions:
      $(c Y)
              repo : ${repo}
            builds : ${builds}
         condition : ${condition}
              show : ${show}
               api : $( [ 'info' == "${show}" ] \
                        && echo "${RT_URL}/api/build/${builds}/${condition}" \
                        || echo "${RT_URL}/api/search/aql" \
               )
      $(c)
    """

    if [ 'info' = "${show}" ]; then
      curl "${CURL_OPT[@]}" \
           -X GET "${RT_URL}/api/build/${builds}/${condition}"
    else
      curl "${CURL_OPT[@]}" \
           -H "Content-Type: text/plain" \
           -X POST ${RT_URL}/api/search/aql \
           -d """items.find ({ \
                   \"repo\": \"${rtProj}-${rtName}-local\", \
                   \"type\" : \"folder\" , \
                   \"depth\" : \"1\", \
                   \"created\" : { \"\$before\" : \"$condition\" } \
                })
              """ \
           "${extra}"
    fi
  fi
}

function rtdel() {
  # shellcheck disable=SC2155
  local USAGE="""
  $(c sM)rtdel$(c) - artifactory clean - clean artifacts in Artifactory via repo and build info

  SYNOPSIS
    $(c sY)\$ rtdel [bdi] [vwi] [repo] [build-id]$(c)

  EXAMPLE
    $(c G)\$ rtdel integration 1234$(c)
  """
  local rtProj="${RT_PROJECT}"

  if [ 2 -gt $# ]; then
    echo -e "${USAGE}"
  else
    case $1 in
      [wW] | [vV] | [iI] )
        [ 3 -ne $# ] && echo -e "${USAGE}"
        p=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
        [ 'w' == "${p}" ] && rtProj='project-1'
        [ 'v' == "${p}" ] && rtProj='project-2'
        [ 'i' == "${p}" ] && rtProj='project-3'
        rtName="$2"
        buildID="$3"
        ;;
      * )
        rtName="$1"
        buildID="$2"
        ;;
    esac

    repo="${rtProj}-${rtName}-local"
    build="${rtProj} - ${rtName}"
    if /usr/bin/curl "${CURL_OPT[@]}" -X GET "${RT_URL}/api/repositories" | jq .[].key | grep "${repo}" > /dev/null 2>&1; then
      echo """
            repo : ${repo}
           build : ${build}
        build id : ${buildID}
      """
      /usr/bin/curl "${CURL_OPT[@]}" -X DELETE "${RT_URL}/${repo}/${buildID}"
      /usr/bin/curl "${CURL_OPT[@]}" -X DELETE "${RT_URL}/api/build/${build}?buildNumbers=${buildID}&artifacts=1"
      # curl -X DELETE "${CURL_OPT[@]}" "${RT_URL}/api/trash/clean/${repo}/${buildID}"
      # curl -X DELETE "${CURL_OPT[@]}" "${RT_URL}/api/trash/clean/artifactory-build-info"
    else
      echo "${rtName} repo cannot be found for ${rtProj}"
      echo -e "${USAGE}"
    fi
  fi
}

function rtbdi() {
  # shellcheck disable=SC2155
  local USAGE="""
  $(c sM)rtbdi$(c) - artifactory build discard - clean artifacts in Artifactory via build info

  SYNOPSIS
    $(c sY)\$ rtbdi [wvi] [repo] [build-id [build-id [build-id]]]

  EXAMPLE
    $(c Wdi)# remove both build info and artifacts in vail precommit #520$(c)
    $(c G)\$ rtbdi i precommit 520$(c)
  """
  rtProj="${RT_PROJECT}"

  if [ 2 -gt $# ]; then
    echo -e "${USAGE}"
  else
    case $1 in
      [wW] | [vV] | [iI] )
        p=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
        [ 'w' == "${p}" ] && rtProj='project-1'
        [ 'v' == "${p}" ] && rtProj='project-2'
        [ 'i' == "${p}" ] && rtProj='project-3'
        rtName="$2"
        # [using ${@: -x} for zsh or dash](https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script#comment77482131_1853946)
        buildID="${*: -$(( $#-2 ))}"
        ;;
      * )
        rtName="$1"
        buildID="${*: -$(( $#-1 ))}"
        ;;
    esac

    buildName="${rtProj} - ${rtName}"
    bid=$(curl -sg -X GET "${RT_URL}/api/build/${buildName}" | jq --raw-output .buildsNumbers[].uri)
    for _i in ${buildID}; do
      if echo "${bid}" | grep -E "/${_i}" >/dev/null; then
        info="""following build info and associate artifacts gonna be removed:\n
             project : ${rtProj}
           repo name : ${rtProj}-${rtName}-local
          build name : ${buildName}
            build id : ${_i}
             api url : ${RT_URL}/api/build/${buildName}?buildNumbers=${_i}&artifacts=1$(c)
        """
        echo -e "$(c Y)${info}$(c)"
        curl -sIg \
             -X DELETE \
             "${RT_URL}/api/build/${buildName}?buildNumbers=${_i}&artifacts=1"
      else
        echo -e "$(c Y)${_i} in \"${buildName}\" cannot be found. you many want try search via props.$(c)"
      fi
    done
  fi
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
