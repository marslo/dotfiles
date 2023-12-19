#!/usr/bin/env bash
# shellcheck disable=SC1078,SC1079,SC2086,SC2155
# =============================================================================
#    FileName : g.sh
#      Author : marslo.jiao@gmail.com
#     Created : 2012
#  LastChange : 2020-10-20 21:50:38
#        Desc : for git
# =============================================================================

# git fetch
function gf() {
  GITDIR=${1%%/}
  GITBRANCH=$2
  ISStashed=false
  pushd . > /dev/null
  cd "${GITDIR}" || return
  echo -e "$(c B)=== ${GITDIR} »$(c) $(c Y)${GITBRANCH}$(c) $(c B)===$(c)"

  if git rev-parse --git-dir > /dev/null 2>&1; then
    untracked=$(git ls-files --others --exclude-standard)
    modified=$(git ls-files --modified --exclude-standard)
    currentBr=$(git rev-parse --abbrev-ref HEAD)
    [ -n "${untracked}" ] && echo -e "$(c M)UNTRACKED FILES in ${currentBr}: $(echo ${untracked} | paste -sd ' ' -)$(c)"
    if test -d "$(git rev-parse --git-path rebase-merge)" || test -d "$(git rev-parse --git-path rebase-apply)" ; then
      echo -e "$(c R)The current repo is in the rebase procedss. exit.$(c)"
      popd > /dev/null || return
      return 1 2>/dev/null
      # shellcheck disable=SC2317
      exit 1
    fi

    if ! git branch -a | "${GREP}" "${GITBRANCH}" > /dev/null 2>&1; then
      GITBRANCH=$(git rev-parse --abbrev-ref HEAD)
    fi

    # checkout branch to $GITBRANCH
    if [ "${currentBr}" != "${GITBRANCH}" ]; then
      if [ -n "${modified}" ]; then
        echo -e "$(c R)GIT STASH: ${GITDIR} : ${currentBr} !!$(c)"
        git stash save "auto-stashed by gf command"
        ISStashed=true
      fi
      echo -e "$(c Y)~~> ${GITBRANCH}$(c)"
      git checkout "${GITBRANCH}"
    fi

    # remove the local branch if the branch has been deleted in remote
    if git remote prune origin --dry-run | ${GREP} prune; then
      for pruneBr in $(git remote prune origin --dry-run | sed -rn 's@.*\[would prune\]\s*origin/(.*)$@\1@gp'); do
        if [ "${currentBr}" = "${pruneBr}" ] && [ -z "${modified}" ]; then
          echo -e "$(c Y)The current branch ${currentBr} has been pruned in remote. And the current branch has no modified files!$(c)"
          defaultBr="$(git ls-remote --symref origin HEAD | sed -rn 's@^ref:.*heads/(\S*).*$@\2@p')"
          echo -e "$(c Y)~~> ${defaultBr}$(c)"
          git checkout "${defaultBr}"
        elif [ "${currentBr}" = "${pruneBr}" ] && [ -n "${modified}" ]; then
          echo -e "$(c R)current branch ${currentBr} has been removed in remote, but there's modified files in local. exit$(c)"
          # return 1 2>/dev/null
          # exit 1
        fi

        if git rev-parse --verify --quiet "${pruneBr}" > /dev/null; then
          echo -e "$(c M)== REMOVE LOCAL BRANCH: ${pruneBr}$(c)"
          if ! git branch -D "${pruneBr}"; then
            echo -e "$(c R)WARNING: REMOVE LOCAL BRANCH ${pruneBr} failed!!$(c)"
          fi
        fi
      done
    fi

    # git gfall on ${GITBRANCH}
    if [[ "$GITBRANCH" == 'meta/config' ]]; then
      git fetch origin --force refs/meta/config:refs/remotes/origin/meta/config
      # git pull origin refs/meta/config
      # git merge ${GITBRANCH}
    else
      git fetch origin --prune
      git fetch --all --force
    fi
    git rebase -v --all refs/remotes/origin/${GITBRANCH}
    if test -d "$(git rev-parse --git-path rebase-merge)" || test -d "$(git rev-parse --git-path rebase-apply)" ; then
      echo -e "$(c Y) ${GITBRANCH} rebase failed due to un-resolve the conflicts$(c)"
    fi
    git merge --all --progress refs/remotes/origin/${GITBRANCH}
    git update-ref -d refs/${GITBRANCH}
    git remote prune origin

    if git --no-pager config --file "$(git rev-parse --show-toplevel)/.gitmodules" --get-regexp url; then
      git submodule sync --recursive
      git submodule update --init --recursive
    fi

    # restore the current working branch
    if ${ISStashed}; then
      echo -e "$(c Y)~~> ${currentBr}$(c)"
      git checkout "${currentBr}"
      git stash pop
      echo -e "\\033[35mGIT STASH POP: ${GITDIR} : ${currentBr}\\033[0m"
    fi
  else
    echo -e "\\033[33mNOT Git Repo!!\\033[0m"
  fi
  popd > /dev/null || return
}

# git fetch dir
function gfdir() {
  myDir="$1"
  [ 2 -eq $# ] && br="$2"
  for i in $(${LS} -1d "${myDir%%/}"/); do
    [ -z "${br}" ] && br=$(git -C ${i} rev-parse --abbrev-ref HEAD)
    gf "${i}" "${br}"
  done
}

# git fetch all (dir)
function gfall() {
  if [ 1 -eq $# ]; then
    dir="$1"
  elif git rev-parse --git-dir > /dev/null 2>&1; then
    dir=$(dirname "$(git rev-parse --git-dir)")
  else
    # shellcheck disable=SC2046
    dir=$(dirname $(find . -type d \( -not -path "*archive/*" -not -path "*archives/*" \) -name '.git') | uniq)
  fi

  for d in ${dir}; do
    if [ 2 -eq $# ]; then
      br="$2"
    else
      br=$(git -C ${d} rev-parse --abbrev-ref HEAD)
    fi

    gf "${d}" "${br}"
  done
}

function mybr() {
  myBranch=$1
  mainBranch="dev"
  set +H
  # shellcheck disable=SC2035
  for i in $(${LS} -1d */); do
    pushd . > /dev/null
    cd "$i" || return
    dirPath=${i%%/}
    if git rev-parse --git-dir > /dev/null 2>&1; then
      currentBr=$(git rev-parse --abbrev-ref HEAD)
      if [ -z "${myBranch}" ]; then
        echo "${currentBr}" | ${GREP} -v -i "${mainBranch}" > /dev/null 2>&1 && echo -e "$(c B)${dirPath}\\t: ${currentBr}$(c)"
      else
        if echo "${currentBr}" | ${GREP} -i "${myBranch}" > /dev/null 2>&1; then
          echo -e "$(c Y)** ${dirPath}\\t: ${currentBr}$(c)"
        elif [ ! "${currentBr}" = "${mainBranch}" ]; then
          echo -e "$(c B)${dirPath}\\t: NOT ${mainBranch} : ${currentBr} !!$(c)"
        fi
      fi
    fi
    popd > /dev/null || return
  done
}

function gitclean() {
  set +H
  # shellcheck disable=SC2035
  for i in $(${LS} -1d */); do
    GITDIR=${i%%/}
    echo -e "=== \\033[32m ${GITDIR} \\033[0m ==="
    pushd . > /dev/null
    cd "${GITDIR}" || return
    git clean -dfx
    git checkout -- *
    git reset --hard
    popd > /dev/null || return
  done
}

function grt() {
  usage="""\t$(c B)g$(c)it $(c M)r$(c)ename $(c R)t$(c)ag - rename tag with original committer and date
  \nSYNOPSIS$(c sY)
  \t\$ grt [p|-p|push|--push] <SOURCE_TAG> <NEW_TAG> $(c)
  \nEXAMPLE$(c G)
  \t\$ grt docker.v2.0           docker.x
  \t\$ grt docker.v2.0           refs/tags/docker.x
  \t\$ grt refs/tags/docker.v2.0 docker.x
  \t\$ grt refs/tags/docker.v2.0 refs/tags/docker.x $(c)
  \nOPT
  \t$(c B)p$(c), $(c B)-p$(c), $(c B)push$(c), $(c B)--push$(c) : push changes into remote repository
  """
  if [ 2 -eq $# ]; then
    declare push="false"
    declare sourceTag="""$(echo "$1" | sed -re "s:^(refs/)?(tags/)?(.*)$:\3:")"""
    declare newTag="""$(echo "$2" | sed -re "s:^(refs/)?(tags/)?(.*)$:\3:")"""
  elif [ 3 -eq $# ] && { [ 'p' = "$1" ] || [ '-p' = "$1" ] || [ 'push' = "$1" ] || [ '--push' = "$1" ]; }; then
    declare push="true"
    declare sourceTag="""$(echo "$2" | sed -re "s:^(refs/)?(tags/)?(.*)$:\3:")"""
    declare newTag="""$(echo "$3" | sed -re "s:^(refs/)?(tags/)?(.*)$:\3:")"""
  else
    echo -e "${usage}"
    return
  fi
  declare objectType="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(objecttype)")"""
  echo -e "$(c Y)~~> rename$(c) $(c R)${objectType}$(c) $(c Y): ${sourceTag} to ${newTag}$(c)"
  if [ 'tag' = "${objectType}" ]; then
    declare objectName="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(*objectname)")"""
    declare contents="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(contents)")"""
    GIT_TAGGER_NAME="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(taggername)")"""   \
    GIT_TAGGER_EMAIL="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(taggeremail)")""" \
    GIT_TAGGER_DATE="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(taggerdate)")"""   \
    git tag -a "${newTag}" "${objectName}" -m "${contents}"
  else
    declare objectName="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(objectname)")"""
    GIT_COMMITTER_NAME="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(committername)")"""   \
    GIT_COMMITTER_EMAIL="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(committeremail)")""" \
    GIT_COMMITTER_DATE="""$(git for-each-ref "refs/tags/${sourceTag}" --format="%(committerdate)")"""   \
    git tag "${newTag}" "${objectName}"
  fi
  git tag -d "${sourceTag}"
  if [ 'true' = "${push}" ]; then
    echo -e "$(c Y)~~> push ${newTag} and remove ${sourceTag}$(c)"
    git push origin "${newTag}" ":${sourceTag}"
    git pull --prune --tags
  fi
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh
