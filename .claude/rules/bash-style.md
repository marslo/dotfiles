# Bash Style

> Migrated from `~/.cursor/rules/bash-style.mdc` (Cursor scope `globs: **/*.sh`).
> Claude Code loads this globally, not glob-scoped — apply it when writing or editing Bash scripts.

Apply these conventions when writing or editing Bash scripts.

## Shebang

Always `#!/usr/bin/env bash` — portable, resolves bash 5.x from PATH (Homebrew).
Never hardcode `#!/bin/bash` (macOS system bash 3.2) or `#!/opt/homebrew/bin/bash`.

```bash
#!/usr/bin/env bash         # ✅ portable, PATH-resolved
#!/bin/bash                 # ❌ macOS system bash 3.2
#!/opt/homebrew/bin/bash    # ❌ hardcoded path — not portable
```

## 1. Naming

- **UPPER_CASE_WITH_UNDERSCORES** (Java-style constants) for global variables,
  variables set from CLI argument/option parsing, and anything treated as a
  constant/config: `ROOT`, `GLOBAL_PATH`, `ME`, `CURRENT_ROOT`, `PREFIX`, `DO_PATH`.
- **camelCase** for ordinary local working variables and for all function names:
  `buildNumber`, `tmpFile`; `installCli()`, `fetchLogs()`.

```bash
# ✅ good
declare -r ROOT="$(pwd)"          # global / constant
function fetchLogs() {            # function → camelCase
  local buildNumber="${1}"        # local working var → camelCase
}

# ❌ bad
declare -r root="$(pwd)"
function fetch_logs() { local BuildNumber="${1}"; }
```

## 2. Always brace expansions

Reference every variable as `${var}` — never bare `$var` (positionals too: `${1}`, `"${@}"`, `${#}`).

```bash
echo "${NAME}"   ;   rm -rf "${DIR}/output"   ;   run "${@}"     # ✅
echo "$name"     ;   rm -rf "$dir/output"     ;   run "$@"       # ❌
```

## 3. Space the outermost bracket when brackets nest

When a statement nests brackets/parens/braces `([{}])`, pad the **outermost** pair
with a space on each side; inner pairs stay tight.

```bash
ROOT="$( cd "$(dirname "${0}")" && pwd )"        # ✅ outer padded, inner tight
files=( "${dir}"/*.log )                         # ✅

ROOT="$(cd "$(dirname "${0}")" && pwd)"          # ❌
files=("${dir}"/*.log)                           # ❌
```

## 4. Single-quote hardcoded strings

If a string has no expansion (no variable, no command sub), use single quotes;
use double quotes only when interpolating.

```bash
msg='hello world'         ;   path="${ROOT}/output"     # ✅
msg="hello world"                                       # ❌
```

## 5. Yoda comparisons — literal on the left

In equality tests, put the hardcoded literal on the left, the variable on the right.

```bash
test 'abc' = "${VAR}"          # ✅
test "${VAR}" = 'abc'          # ❌
```

## 6. Prefer `test` over `[[ ... ]]` / `[ ... ]`

For portability, prefer `test EXPR`. Fall back to `[[ ... ]]` only when you need
its extras — regex `=~`, glob `==`, or a compound condition that's clearer grouped.

```bash
test -f "${FILE}"                       # ✅ portable
test -n "${X}" && test '-' != "${X}"    # ✅ chain with shell &&

[[ -f "${FILE}" ]]                      # ❌ when plain test suffices
[[ "${VAL}" =~ ^[0-9]+$ ]]              # ✅ OK — regex needs [[ ]]
```

## 7. Collapse simple if/else into `&&` / `||`

- single-branch `if`  →  `test COND && cmd`   (or `test COND || cmd`)
- two-branch with single statements  →  `test COND && cmd1 || cmd2`

```bash
test -d "${DIR}" && rm -rf "${DIR}"                  # ✅ single-branch
test -f "${F}"   || echo 'missing' >&2               # ✅
test -f "${F}" && echo 'found' || echo 'missing'     # ✅ two-branch
```

⚠ Pitfall: in `A && cmd1 || cmd2`, `cmd2` also runs if `cmd1` fails. When `cmd1`
may fail — or the branch **returns a value** — keep a full `if/else/fi`:

```bash
if test -f "${F}"; then status='ok'; else status='no'; fi
```

## 8. Build commands as arrays — never `eval`

Assemble a command in an indexed array and run it via `"${CMD[@]}"`; never
concatenate into a string and `eval`. Arrays keep word boundaries intact (no
re-splitting, no re-globbing, no quote-injection) and stay `command`-prefixable.

```bash
# ✅ global / config command → UPPER_CASE
declare -a CMD=( command rg --color=never "${PATTERN}" "${DIR}" )
"${CMD[@]}"

# ✅ local working command → camelCase
local -a lsCmd=( command ls -la "${target}" )
"${lsCmd[@]}"

# ✅ conditionally extend, then run once
declare -a CMD=( command git log )
test -n "${SINCE}" && CMD+=( --since "${SINCE}" )
"${CMD[@]}"

# ❌ eval spawns a subshell and re-parses — word-splitting & injection risk
eval "command ls -la ${target}"
# ❌ unquoted string command — splits/globs on whitespace in values
cmd="command grep ${PATTERN} ${DIR}"; ${cmd}
```

## 9. GNU tools on macOS (prefer over BSD)

macOS ships BSD variants of `sed`/`awk`/`date`/`tar`/… whose flags and behavior differ from GNU. On this Mac the GNU versions are installed via Homebrew — **prefer them** so scripts behave the same as on Linux. The `gnubin` dirs are not on the default non-interactive PATH, so invoke by **full path** (or prepend the relevant `gnubin` dir to PATH).

| tool | GNU path (full) | formula |
|---|---|---|
| `sed` | `/opt/homebrew/opt/gnu-sed/libexec/gnubin/sed` | gnu-sed |
| `awk` | `/opt/homebrew/opt/gawk/libexec/gnubin/awk` | gawk |
| `grep` / `egrep` / `fgrep` | `/opt/homebrew/opt/grep/libexec/gnubin/grep` | grep |
| `find` / `xargs` / `locate` | `/opt/homebrew/opt/findutils/libexec/gnubin/find` | findutils |
| `tar` | `/opt/homebrew/opt/gnu-tar/libexec/gnubin/tar` | gnu-tar |
| `which` | `/opt/homebrew/opt/gnu-which/libexec/gnubin/which` | gnu-which |
| `indent` | `/opt/homebrew/opt/gnu-indent/libexec/gnubin/indent` | gnu-indent |
| `getopt` | `/opt/homebrew/opt/gnu-getopt/bin/getopt` | gnu-getopt |
| `diff` / `cmp` / `diff3` / `sdiff` | `/opt/homebrew/opt/diffutils/bin/diff` | diffutils |
| `envsubst` / `gettext` / `msg*` | `/opt/homebrew/opt/gettext/bin/envsubst` | gettext |
| coreutils (`sort`, `date`, `ls`, `cat`, `head`, `tail`, `cut`, `wc`, `cp`, `mv`, `rm`, `stat`, `tr`, `seq`, `split`, `du`, `df`, `tee`, …) | `/opt/homebrew/opt/coreutils/libexec/gnubin/<tool>` | coreutils |
| inetutils (`ping`, `telnet`, `ftp`, `hostname`, `whois`, …) | `/opt/homebrew/opt/inetutils/libexec/gnubin/<tool>` | inetutils |

> [!NOTE]
> `/usr/local/bin/awk` is a symlink to `/opt/homebrew/bin/gawk` (GNU Awk) — same binary as the `gawk` gnubin path above; either works.

To use bare names for a whole script, prepend the dirs once at the top:

```bash
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gawk/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:${PATH}"
```

Fallback: if a GNU binary isn't present, fall back to the BSD tool but keep flags POSIX-portable.
