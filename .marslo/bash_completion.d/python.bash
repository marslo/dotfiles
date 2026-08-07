#!/usr/bin/env bash
# =============================================================================
#      FileName : python.bash
#        Author : marslo
#       Created : 2026-08-06 19:16:53
#    LastChange : 2026-08-06 19:36:25
# =============================================================================
# bash completion for the `python` / `python3[.x]` interpreters:
#   * `python -<opt>`      → short options only; `python --<opt>` → long options only; `--check-hash-based-pycs` value is always|default|never
#   * `python -m <module>` → top-level importable modules, memoized per shell session (first TAB spawns python ~50ms, then instant); refresh with: unset __PY_MODCACHE
#   * `python -m pip …`    → delegates to pip.bash's _pip_core (soft dependency)
#   * anything else        → readline default (files / scripts)
# options verified against python 3.14 `--help` / `--help-all`.
# note: for cross-shell persistence, swap _python_modules for a file cache.

# mapfile / [[ ]] need bash 4+; on older bash leave python's default (filename)
# completion untouched.
test "${BASH_VERSINFO[0]:-0}" -lt 4 && return 0 2>/dev/null

# interpreter options and option values; fills COMPREPLY and returns 0 on a
# match, else 1. short opts from `--help`, long from `--help-all`.
#   `-<TAB>` → short only   ·   `--<TAB>` → long only   ·   `-m<TAB>` → adds a
#   space (unique match), enabling module completion on the next TAB.
_python_opt() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]:-}"
  if test '--check-hash-based-pycs' = "${prev}"; then    # value has choices
    mapfile -t COMPREPLY < <( compgen -W 'always default never' -- "${cur}" )
    return 0
  fi
  if [[ "${cur}" == --* ]]; then                         # long options
    mapfile -t COMPREPLY < <( compgen -W \
      '--check-hash-based-pycs --help --help-all --help-env --help-xoptions --version' \
      -- "${cur}" )
    return 0
  fi
  if [[ "${cur}" == -* ]]; then                          # short options
    mapfile -t COMPREPLY < <( compgen -W \
      '-B -E -I -O -P -S -V -W -X -b -c -d -h -i -m -q -s -u -v -x' -- "${cur}" )
    return 0
  fi
  return 1
}

# populate __PY_MODCACHE[<py>] with that interpreter's top-level importable modules, memoized per shell session. must run in the current shell, so the cache write survives; caller reads the array.
# first call spawns python (~50ms); later calls are a no-op.
declare -gA __PY_MODCACHE=()
_python_modules() {
  local py="${1}"
  test -n "${__PY_MODCACHE[${py}]+x}" && return
  __PY_MODCACHE[${py}]="$(
    "${py}" -c 'import pkgutil, sys, os
paths = [p for p in sys.path if p not in ("", ".", os.getcwd())]  # drop cwd → cacheable
mods = set(sys.builtin_module_names) | {m.name for m in pkgutil.iter_modules(paths)}
print(" ".join(sorted(m for m in mods if m.isidentifier() and not m.startswith("_"))))' 2>/dev/null
  )"
}

# dispatcher registered for the interpreters
_python() {
  # only once `-m` is its own word (cword >= 2) do we complete module / pip;
  # while still typing `-m` itself (cword 1) it falls through to option names.
  if test '-m' = "${COMP_WORDS[1]:-}" && test "${COMP_CWORD}" -ge 2; then
    # module name right after `-m` → cached top-level module list
    if test 2 -eq "${COMP_CWORD}"; then
      local py="${COMP_WORDS[0]}"
      _python_modules "${py}"                            # populate cache (once)
      mapfile -t COMPREPLY < <( \
        compgen -W "${__PY_MODCACHE[${py}]}" -- "${COMP_WORDS[2]:-}" )
      return
    fi
    # `-m pip …` → hand to pip's engine when pip.bash is loaded
    if test 'pip' = "${COMP_WORDS[2]:-}" && declare -F _pip_core >/dev/null 2>&1; then
      # RUNNER is consumed by _pip_core (pip.bash) via dynamic scope
      # shellcheck disable=SC2034
      local -a RUNNER=( "${COMP_WORDS[0]}" -m pip )
      local -a argv=( pip "${COMP_WORDS[@]:3:$(( COMP_CWORD - 2 ))}" )
      _pip_core "${argv[@]}"
      return
    fi
    # other `-m <module> …` → that module's own args → files
    COMPREPLY=()
    compopt -o default 2>/dev/null
    return
  fi
  # interpreter options (incl. `-m` → adds space), else readline default (files)
  _python_opt && return
  COMPREPLY=()
  compopt -o default 2>/dev/null
}

complete -F _python python python3 python3.14

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
