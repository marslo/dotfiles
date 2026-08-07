#!/usr/bin/env bash
# =============================================================================
#      FileName : pip.bash
#        Author : marslo
#       Created : 2025-12-02 18:14:52
#    LastChange : 2026-08-06 19:17:38
# =============================================================================
#
# pip bash completion — value-aware, space-form (`--opt value`)
#
# supersedes the stock `pip completion --bash` output. on top of pip's own
# PIP_AUTO_COMPLETE (still used live for command / option / package names, so
# they never go stale across pip versions) it adds:
#   * option-value completion:  `--opt <TAB>`  and  `--opt=<TAB>`
#   * choice sets                (e.g. --format → columns freeze json)
#   * file / dir / path values   (e.g. -r → *.txt, --target → dirs)
#   * config / cache sub-actions (list edit get set unset / dir info purge …)
#   * installed-package names for uninstall / show
# choice & path values resolve from a static table (no pip subprocess) —
# verified against pip 26.2.1, https://pip.pypa.io/en/latest/cli/

# associative arrays need bash 4+; on older bash fall back to pip's basic
# completion so the file loads cleanly instead of erroring out.
if test "${BASH_VERSINFO[0]:-0}" -lt 4; then
  _pip_completion() {
    # word-splitting is intentional: mapfile is unavailable on the bash 3.x this branch targets, and pip may emit one candidate per line
    # shellcheck disable=SC2207
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" COMP_CWORD="${COMP_CWORD}" PIP_AUTO_COMPLETE=1 "${1}" 2>/dev/null ) )
  }
  complete -o default -F _pip_completion pip pip3
  # exit only reached if the file is executed directly rather than sourced
  # shellcheck disable=SC2317
  return 0 2>/dev/null || exit 0
fi

# ===========================================================================
# value spec table:  OPTION -> completion type for the value it accepts
#   "a b c"   literal choice set
#   @file     file path
#   @dir      directory path
#   @path     file or dir  (local project / url / archive)
#   @none     arbitrary value (url, number, KEY=VALUE) → complete nothing
# key forms:  "<opt>"        applies to every command
#             "<cmd>/<opt>"  command-specific, wins over the bare form
# short flags are registered next to their long form where they take a value.
# ===========================================================================
declare -gA __PIP_VAL=(
  # --- choice sets -----------------------------------------------------------
  ['--progress-bar']='auto on off raw'
  ['--upgrade-strategy']='eager only-if-needed'
  ['--root-user-action']='warn ignore'
  ['--keyring-provider']='auto disabled import subprocess'
  ['--exists-action']='s i w b a'
  ['--use-feature']='fast-deps inprocess-build-deps venv-isolation truststore no-binary-enable-wheel-cache build-constraint'
  ['--use-deprecated']='legacy-resolver legacy-certs'
  ['--implementation']='pp jy cp ip py'
  ['list/--format']='columns freeze json'
  ['cache/--format']='human abspath'
  ['hash/--algorithm']='sha256 sha384 sha512'
  ['hash/-a']='sha256 sha384 sha512'
  ['--no-binary']=':all: :none:'
  ['--only-binary']=':all: :none:'
  ['--all-releases']=':all: :none:'
  ['--only-final']=':all: :none:'

  # --- file values -----------------------------------------------------------
  ['--requirement']='@file'   ['-r']='@file'
  ['--constraint']='@file'    ['-c']='@file'
  ['--build-constraint']='@file'
  ['--requirements-from-script']='@file'
  ['--report']='@file'
  ['--log']='@file'
  ['--cert']='@file'
  ['--client-cert']='@file'
  ['--editor']='@file'
  ['lock/--output']='@file'   ['lock/-o']='@file'

  # --- directory values ------------------------------------------------------
  ['--target']='@dir'         ['-t']='@dir'
  ['--prefix']='@dir'
  ['--root']='@dir'
  ['--src']='@dir'
  ['--wheel-dir']='@dir'      ['-w']='@dir'
  ['--cache-dir']='@dir'
  ['--path']='@dir'
  ['download/--dest']='@dir'  ['download/-d']='@dir'
  ['--build']='@dir'          ['-b']='@dir'

  # --- path / url values -----------------------------------------------------
  ['--editable']='@path'      ['-e']='@path'
  ['--find-links']='@path'    ['-f']='@path'

  # --- arbitrary values (offer nothing, but never fall back to option dump) --
  ['--index-url']='@none'     ['-i']='@none'
  ['--extra-index-url']='@none'
  ['--pypi-url']='@none'
  ['--proxy']='@none'
  ['--trusted-host']='@none'
  ['--python']='@none'
  ['--python-version']='@none'
  ['--platform']='@none'
  ['--abi']='@none'
  ['--config-settings']='@none'   ['-C']='@none'
  ['--global-option']='@none'
  ['--build-option']='@none'
  ['--install-option']='@none'
  ['--group']='@none'
  ['--exclude']='@none'
  ['--refresh-package']='@none'
  ['--uploaded-prior-to']='@none'
  ['--retries']='@none'
  ['--timeout']='@none'
  ['--default-timeout']='@none'
)

# positional sub-actions of a command (pip's own completion omits these)
declare -gA __PIP_SUBCMD=(
  ['config']='list edit get set unset debug help'
  ['cache']='dir info list remove purge'
  ['index']='versions'
)

# commands whose positional is an installed-package name / a local path
declare -gr __PIP_PKG_CMDS=' uninstall show '
declare -gr __PIP_PATH_CMDS=' install download wheel lock '

# --- helpers ---------------------------------------------------------------

# file / dir completion — prefer bash-completion's _filedir when loaded
__pipFiledir() {
  local mode="${1:-}"                                    # 'dir' or empty
  if declare -F _filedir >/dev/null 2>&1; then
    if test 'dir' = "${mode}"; then _filedir -d; else _filedir; fi
    return
  fi
  compopt -o filenames 2>/dev/null
  local line
  if test 'dir' = "${mode}"; then
    while IFS= read -r line; do COMPREPLY+=( "${line}" ); done \
      < <( compgen -d -- "${cur}" )
  else
    while IFS= read -r line; do COMPREPLY+=( "${line}" ); done \
      < <( compgen -f -- "${cur}" )
  fi
}

# echo the value spec for (cmd, opt); command-specific form wins
__pipValueSpec() {
  local cmd="${1}" opt="${2}"
  if test -n "${__PIP_VAL[${cmd}/${opt}]+x}"; then
    printf '%s' "${__PIP_VAL[${cmd}/${opt}]}"
  elif test -n "${__PIP_VAL[${opt}]+x}"; then
    printf '%s' "${__PIP_VAL[${opt}]}"
  fi
}

# complete the value of an option; return 1 when the option has no value spec
__pipCompleteValue() {
  local cmd="${1}" opt="${2}"
  local spec; spec="$( __pipValueSpec "${cmd}" "${opt}" )"
  test -z "${spec}" && return 1
  case "${spec}" in
    '@none' ) : ;;                                       # arbitrary → nothing
    '@file' ) __pipFiledir ;;
    '@dir'  ) __pipFiledir dir ;;
    '@path' ) __pipFiledir ;;
    *       ) mapfile -t COMPREPLY < <( compgen -W "${spec}" -- "${cur}" ) ;;
  esac
  return 0
}

# delegate to pip's PIP_AUTO_COMPLETE, stripping trailing '=' so results are
# space-form (`--opt value`).  RUNNER[] = how to invoke pip.
__pipDelegate() {
  local -a argv=( "${@}" )
  local raw w
  raw="$( COMP_WORDS="${argv[*]}" COMP_CWORD="$(( ${#argv[@]} - 1 ))" PIP_AUTO_COMPLETE=1 "${RUNNER[@]}" 2>/dev/null )"
  for w in ${raw}; do COMPREPLY+=( "${w%=}" ); done
}

# --- core ------------------------------------------------------------------
# args: emulated pip argv (element 0 == 'pip'); last element is the word being
# completed.  requires RUNNER[] set by the caller.
_pip_core() {
  local -a argv=( "${@}" )
  local last=$(( ${#argv[@]} - 1 ))
  local cur="${argv[last]}" prev=''
  test "${last}" -ge 1 && prev="${argv[last-1]}"
  COMPREPLY=()

  # normalize the `--opt=value` form (readline splits on '=')
  local eqopt=''
  if [[ "${cur}" == -*=* ]]; then                        # single token --o=val
    eqopt="${cur%%=*}"; cur="${cur#*=}"
  elif test '=' = "${cur}"; then                         # `--opt=` (empty val)
    eqopt="${prev}"; cur=''
  elif test '=' = "${prev}"; then                        # split: .. --opt = val
    eqopt="${argv[last-2]}"
  fi

  # locate the subcommand: first bare token after the binary, skipping global
  # options and their values
  local cmd='' cmdidx=0 i tok pending=''
  for (( i=1; i<last; i++ )); do
    tok="${argv[i]}"
    test '=' = "${tok}" && { pending=''; continue; }
    if test '-' = "${tok:0:1}"; then pending="${tok}"; continue; fi
    if test -n "${pending}" && test -n "$( __pipValueSpec '' "${pending}" )"; then
      pending=''; continue                               # tok is that opt value
    fi
    cmd="${tok}"; cmdidx="${i}"; break
  done

  # 1. no subcommand yet → pip lists commands (+ global options)
  if test -z "${cmd}"; then
    __pipDelegate "${argv[@]}"
    return
  fi

  # 2. value completion
  if test -n "${eqopt}"; then                            # `--opt=` form
    __pipCompleteValue "${cmd}" "${eqopt}"
    return
  fi
  if test '-' = "${prev:0:1}"; then                      # `--opt value` form
    __pipCompleteValue "${cmd}" "${prev}" && return
  fi

  # 3. positional sub-action (config / cache / index)
  if test -n "${__PIP_SUBCMD[${cmd}]+x}"; then
    local sub='' j jtok jpend=''
    for (( j=cmdidx+1; j<last; j++ )); do
      jtok="${argv[j]}"
      test '=' = "${jtok}" && { jpend=''; continue; }
      if test '-' = "${jtok:0:1}"; then jpend="${jtok}"; continue; fi
      if test -n "${jpend}" && test -n "$( __pipValueSpec "${cmd}" "${jpend}" )"; then
        jpend=''; continue
      fi
      sub="${jtok}"; break
    done
    if test -z "${sub}" && test '-' != "${cur:0:1}"; then
      mapfile -t COMPREPLY < <( compgen -W "${__PIP_SUBCMD[${cmd}]}" -- "${cur}" )
      return
    fi
  fi

  # 4. option name → pip's list, '=' stripped (space-form)
  if test '-' = "${cur:0:1}"; then
    __pipDelegate "${argv[@]}"
    return
  fi

  # 5. positional value
  if [[ "${__PIP_PKG_CMDS}" == *" ${cmd} "* ]]; then     # installed pkg names
    __pipDelegate "${argv[@]}"
    return
  fi
  if test 'hash' = "${cmd}"; then                        # archive files
    __pipFiledir
    return
  fi
  if [[ "${__PIP_PATH_CMDS}" == *" ${cmd} "* ]]; then     # pkgs + local paths
    __pipDelegate "${argv[@]}"
    test -n "${cur}" && __pipFiledir                     # paths once typing starts
    return
  fi
  __pipDelegate "${argv[@]}"                              # fallback
}

# entry point for `pip` / `pip3` / `pipX.Y`
_pip() {
  local -a RUNNER=( "${COMP_WORDS[0]}" )
  local -a argv=( "${COMP_WORDS[@]:0:$(( COMP_CWORD + 1 ))}" )
  argv[0]='pip'
  _pip_core "${argv[@]}"
}

complete -F _pip pip pip3

# `python -m pip …` completion now lives in python.bash, which soft-depends on _pip_core defined above.

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
