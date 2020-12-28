#!/bin/bash
# shellcheck disable=SC1078,SC1079,SC2086
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
          echo -e "$(c M)== REMOVE LOCAL BRNACH: ${pruneBr}$(c)"
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
function gfdir()
{
  myDir="$1"
  [ 2 -eq $# ] && br="$2"
  for i in $(${LS} -1d "${myDir%%/}"/); do
    [ -z "${br}" ] && br=$(git -C ${i} rev-parse --abbrev-ref HEAD)
    gf "${i}" "${br}"
  done
}

# git fetch all (dir)
function gfall()
{
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

function mybr()
{
  myBranch=$1
  mainBranch="dev"
  set +H
  for i in $(${LS} -1d */); do
    pushd . > /dev/null
    cd "$i"
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
    popd > /dev/null
  done
}

function gitclean() {
  set +H
  for i in $(${LS} -1d */); do
    GITDIR=${i%%/}
    echo -e "=== \\033[32m ${GITDIR} \\033[0m ==="
    pushd . > /dev/null
    cd "${GITDIR}"
    git clean -dfx
    git checkout -- *
    git reset --hard
    popd > /dev/null
  done
}

# vim: ts=2 sts=2 sw=2 et ft=sh
