#!/bin/bash
# shellcheck disable=SC1078,SC1079
# =============================================================================
#     FileName : irt.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2012
#   LastChange : 2020-10-20 21:53:33
# =============================================================================

RT_URL='https://my.artifactory.com/artifactory'
RT_PROJECT='project-1'
CURL_OPT="-s -g --netrc-file $HOME/.marslo/.netrc"

function rtclean() {
  usage="""$(c sM)rtclean$(c) - artifactory clean - clean artifacts in Artifactory via repo and build info
  \nSYNOPSIS
  \n\t$(c sY)\$ rtclean [bi] [vwi] [repo] [build-id]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ rtclean integration 1234$(c)
  """
  if [ 2 -gt $# ]; then
    echo -e "${usage}"
  else
    case $1 in
      bi )
        # shellcheck disable=SC2046
        rtbdi $(echo "${@: -$(( $#-1 ))}" | cut -d' ' -f1-)
        ;;
      * )
        # shellcheck disable=SC2046
        rtdel $(echo "$@" | cut -d' ' -f1-)
        ;;
    esac
  fi
}

function rtsearch() {
  usage="""$(c sM)rtsearch$(c) - artifactory search - search artifacts and(or) build info in Artifactory via repo and condition
  \nSYNOPSIS
  \n\t$(c sY)\$ rtsearch [bi] [wvi] [repo] [condition] [name|info]$(c)
  \nOPTIONS
  \n\t$(c Y)bi$(c)
  \n\t  search via property
  \nEXAMPLE
  \n\tsearch sub-folder detail info in integration repo 10 days ago:
  \t$(c G)\$ rtsearch integration 10days$(c)
  \n\tsearch sub-folder name ONLY in integration repo 10 days ago:
  \t$(c G)\$ rtsearch integration 10days name$(c)
  \n\tsearch 1234(build number) in maven(reponame) build info:
  \t$(c G)\$ rtsearch maven 1234 info$(c)
  \n\tsearch artifacts built from Jenkins job '*marslo/sandbox*'
  \t$(c G)\$ rtsearch build.url '*marslo*sandbox*'$(c)
  """

  if [ 2 -gt $# ]; then
    echo -e "${usage}"
  else
    case $1 in
      bi )
        # shellcheck disable=SC2046
        rtsp $(echo "${@: -$(( $#-1 ))}" | cut -d' ' -f1-)
        ;;
      * )
        # shellcheck disable=SC2046
        rtsc $(echo "$@" | cut -d' ' -f1-)
        ;;
    esac
  fi
}

function rtsp() {
  usage="""$(c sM)rtsp$(c) - artifactory search with properties - search artifacts via properites
  \nSYNOPSIS
  \n\t$(c sY)\$ rtsp [wvi] [property name] [property value]$(c)
  \nEXAMPLE
  \n\tsearch artifacts built from Jenkins job '*marslo*sandbox*'
  \t$(c G)\$ rtsp build.url '*marslo*sandbox*'$(c)
  """
  rtProj="${RT_PROJECT}"
  repo=''

  if [ 2 -gt $# ]; then
    echo -e "${usage}"
  else
    case $1 in
      [wW] | [vV] | [iI] )
        [ 3 -gt $# ] && echo -e "${usage}"
        p=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
        [ 'w' == "${p}" ] && rtProj='project-1'
        [ 'v' == "${p}" ] && rtProj='project-2'
        [ 'i' == "${p}" ] && rtProj='project-3'
        pName="$2"
        pValue="$3"
        [ 4 -ne $# ] && repo="&repos=${rtProj}-$4-local"
        ;;
      * )
        pName="$1"
        pValue="$2"
        [ 3 -ne $# ] && repo="&repos=${rtProj}-$3-local"
        ;;
    esac

    curl -sg \
         -X GET \
         "${RT_URL}/api/search/prop?${pName}=${pValue}${repo}" \
         | jq --raw-output .results[].uri \
         | sed -re 's:(^.*-local/[^/]+/).*$:\1:' \
         | uniq
  fi

}

function rtsc() {
  usage="""$(c sM)rtsc$(c) - artifactory search with conditional - search artifacts and(or) build info in Artifactory via repo and condition
  \nSYNOPSIS
  \n\t$(c sY)\$ rtsc [wv] [repo] [condition] [name|info]$(c)
  \nEXAMPLE
  \n\tsearch sub-folder detail info in integration repo 10 days ago:
  \t$(c G)\$ rtsc integration 10days$(c)
  \n\tsearch sub-folder name ONLY in integration repo 10 days ago:
  \t$(c G)\$ rtsc integration 10days name$(c)
  \n\tsearch 1234(build number) in maven(reponame) build info:
  \t$(c G)\$ rtsc maven 1234 info$(c)
  """
  rtProj="${RT_PROJECT}"
  show=false
  extra=''

  if [ 2 -gt $# ]; then
    echo -e "${usage}"
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
    builds="${rtProj}- ${rtName}"
    [ 'name' = "${show}" ] && extra='| jq --raw-output .results[].name?'

    echo """
              repo : ${repo}
            builds : ${builds}
         condition : ${condition}
              show : ${show}
    """

    if [ 'info' = "${show}" ]; then
      curl "${CURL_OPT}" \
           -X GET "${RT_URL}/api/build/${builds}/${condition}"
    else
      curl "${CURL_OPT}" \
           -H "Content-Type: text/plain" \
           -X POST ${RT_URL}/api/search/aql \
           -d """items.find ({ \
                   \"repo\": \"${rtProj}-${rtName}-local\", \
                   \"type\" : \"folder\" , \
                   \"depth\" : \"1\", \
                   \"created\" : { \"\$before\" : \"$2\" } \
                })
              """ \
           "${extra}"
    fi
  fi
}

function rtdel() {
  usage="""$(c sM)rtdel$(c) - artifactory clean - clean artifacts in Artifactory via repo and build info
  \nSYNOPSIS
  \n\t$(c sY)\$ rtdel [bdi] [vwi] [repo] [build-id]$(c)
  \nEXAMPLE
  \n\t$(c G)\$ rtdel integration 1234$(c)
  """
  rtProj="${RT_PROJECT}"

  if [ 2 -gt $# ]; then
    echo -e "${usage}"
  else
    case $1 in
      [wW] | [vV] | [iI] )
        [ 3 -ne $# ] && echo -e "${usage}"
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
    build="${rtProj}- ${rtName}"
    if /usr/bin/curl "${CURL_OPT}" -X GET "${RT_URL}/api/repositories" | jq .[].key | grep "${repo}" > /dev/null 2>&1; then
      echo """
            repo : ${repo}
           build : ${build}
        build id : ${buildID}
      """
      /usr/bin/curl "${CURL_OPT}" -X DELETE "${RT_URL}/${repo}/${buildID}"
      /usr/bin/curl "${CURL_OPT}" -X DELETE "${RT_URL}/api/build/${build}?buildNumbers=${buildID}&artifacts=1"
      # curl -X DELETE "${CURL_OPT}" "${RT_URL}/api/trash/clean/${repo}/${buildID}"
      # curl -X DELETE "${CURL_OPT}" "${RT_URL}/api/trash/clean/artifactory-build-info"
    else
      echo "${rtName} repo cannot be found for ${rtProj}"
      echo -e "${usage}"
    fi
  fi
}

function rtbdi() {
  usage="""$(c sM)rtbdi$(c) - artifactory build discard - clean artifacts in Artifactory via build info
  \nSYNOPSIS
  \n\t$(c sY)\$ rtbdi [wvl] [repo] [build-id [build-id [build-id]]]
  \nEXAMPLE
  \n\t$(c G)\$ rtbdi
  """
  rtProj="${RT_PROJECT}"

  if [ 2 -gt $# ]; then
    echo -e "${usage}"
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
           repo name : ${rtName}
          build name : ${buildName}
            build id : ${_i}
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

# vim: ts=2 sts=2 sw=2 et ft=Groovy
