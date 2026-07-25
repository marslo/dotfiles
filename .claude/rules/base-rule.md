# Base Rules

> Migrated from `~/.cursor/rules/base-rule.mdc` (`alwaysApply: true`). Global — applies everywhere.

- Before editing any script, read the original file first with the Read tool.
- Only run `git commit` when I explicitly say "commit"; never push on your own.
- After substantive changes, run lint checks on the files you edited.
- Reply in English when my question is not in Chinese; otherwise reply in Simplified Chinese.

# Code comments

Style for comments in any language (`#`, `//`, `/* */`, `--`, …).

- lowercase by default — no leading capital; keep uppercase only for terms that demand it: `ID`, `PR`, `URL`, `API`, `TTL`, `SHA`, acronyms, and proper names.
- describe **what** it is or **what** it does — not **why**, not the underlying mechanism. prefer precise technical terms over prose.
- no 80-column limit: put it on one line if one line says it; wrap only when a single line can't be clear, or when listing an `example` / multiple behaviors.

```python
# append (#ID) to the commit subject; skip if already present    # ✅
# fetch base ref then rebase HEAD onto it                         # ✅

# Appends the pull-request identifier to the commit subject line  # ❌ capitalized, wordy
# we do this because otherwise the log loses the PR link          # ❌ explains why
```

# Shell: prefer modern search tools

When running shell commands, prefer the faster modern replacements:

- `find` → use `command fd`
- `grep` → use `command rg` (ripgrep)

Both are color-aliased, so ALWAYS invoke them with the `command` prefix (i.e.
`command fd` / `command rg`) to bypass the alias and get clean, parseable output.

Fallback: if the modern tool isn't installed (`command -v fd` / `command -v rg`
fails), fall back to the default `find` / `grep`. Prefer a guarded one-liner,
e.g. `command -v fd >/dev/null && command fd PATTERN || command find . -name PATTERN`
and `command -v rg >/dev/null && command rg PATTERN || command grep -rn PATTERN`.

# Shell: bypass color-injecting aliases

When running Linux commands via Shell, any command I (marslo) have aliased that
injects ANSI color or changes behavior MUST be invoked with the `command` prefix
(the raw binary) to get clean, parseable output.

Rule of thumb: if a command's output will be parsed again (pipes, command
substitution, downstream grep/awk/sed), use `command` to bypass the alias.
Purely human-facing interactive output may keep the colored alias.

Known aliases to bypass:

- `grep` / `egrep` / `lgrep` (aliased with `--color=always` plus `-i`/`-n`, which change both color and matching) → use `command grep` / `command egrep`
- `cat` → use `command cat`
- `ls` / `l` / `ll` / `l.` / `ld` (`--color=always`) → use `command ls`
- `rg` (`--color=always`) → use `command rg`, or pass `--color=never`
- `fd` (`--color=always`) → use `command fd`, or pass `--color=never`
- `diff` (`--color=auto`) → in pipes use `command diff`
- `kubecolor` and its aliases (`k` / `kc` / `kd` / `kubectl` / `k3` / `k4` / `k8` / `kt*` / `kl*`, always colored) → when parsing output use `command kubectl`
- `eza` family (`la` / `els` / `etree`, `--icons` forces color) → when parsing use `command ls`
- `ip` (`ip -c`) → use `command ip`

# Git: always bypass the external diff tool

My git is configured with an external/pager diff tool (e.g. difftastic / delta
via `diff.external` or `[pager] diff`). Any command that emits a diff MUST be
run with `--no-ext-diff` so the output is a clean, parseable unified diff:

- `git diff` → `git diff --no-ext-diff`
- `git show` → `git show --no-ext-diff`
- `git log -p` → `git log -p --no-ext-diff`

Add `--no-color` as well when the result will be parsed further.
