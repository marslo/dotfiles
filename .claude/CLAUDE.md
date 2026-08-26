# marslo — global Claude Code rules

Machine-wide rules for every project (the Claude Code analog of `~/.cursor/rules/`). Each rule lives in `~/.claude/rules/*.md` and is imported below;
`base-rule` is the always-on entry, the rest are language-specific.

> Note: unlike Cursor's per-glob `.mdc`, these imports are **always** loaded into
> context (no glob-scoped auto-attach). If a language rule grows large and you'd
> rather load it on demand, move it to a Skill (`~/.claude/skills/<name>/SKILL.md`).

# 0. Core Directives (Highest Priority)

1. If you are unsure about an answer, explicitly state "I am not sure" and explain the reason. Strictly NO guessing or hallucinating information!
2. At the end of every response, provide a confidence score from 1 to 10. Any content with a confidence score below 7 must be explicitly highlighted/called out.
3. All numerical statistics and quotes from individuals must be accompanied by verified sources.

请现在起遵守以下三条规则:

1. 如果你对答案没有把握, 请直接说我不确定并解释原因, 严禁瞎猜假想!
2. 每次回答完后, 请为你的信心指数打分, 1 到 10 分, 任何低于 7 分的内容都要专门标注出来
3. 针对所有的数字统计数据和人物言论必须提供经过验证的来源

**CRITICAL RULE**:

- If not explicitly asked to commit, !!NEVER!! run git commit for any message. Provide the message if necessary, but unless explicitly instructed, you must absolutely not run git commit!
- 如果没有明确的让你提交, !!切勿!! git commit 任何 message. 如果有必要提供就行, 除非我显式的让你提交, 否则一律不得 git commit!

# 1. base-rule (always applied)

1. Before editing any script, read the original file first with the Read tool.
2. When running in a sandbox environment, prepend `/opt/homebrew/bin` to your PATH: `export PATH="/opt/homebrew/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"`.
3. Only run `git commit` when I explicitly say "commit"; never push on your own.
4. After substantive changes, run lint checks on the files you edited.
5. Reply/Chat language — chat answers only: if I ask in Chinese, reply in Simplified Chinese; otherwise reply in English. (code comments are always English — see § 2.)

# 2. Code comments

Style for comments in any language (`#`, `//`, `/* */`, `--`, …).

- language: **always English**, regardless of the conversation language (even when we're chatting in Chinese).
- lowercase by default — no leading capital; keep uppercase only for terms that demand it: `ID`, `PR`, `URL`, `API`, `TTL`, `SHA`, acronyms, and proper names.
- describe **what** it is or **what** it does — not **why**, not the underlying mechanism. prefer precise technical terms over prose.
- no 80-column limit: put it on one line if one line says it; wrap only when a single line can't be clear, or when listing an `example` / multiple behaviors.

```python
# append (#ID) to the commit subject; skip if already present     # ✅
# fetch base ref then rebase HEAD onto it                         # ✅

# Appends the pull-request identifier to the commit subject line  # ❌ capitalized, wordy
# we do this because otherwise the log loses the PR link          # ❌ explains why
```

# 3. Shell/Command

## 3.1. prefer modern search tools

When running shell commands, prefer the faster modern replacements:

- `find` → use `command fd`
- `grep` → use `command rg` (ripgrep)

Both are color-aliased, so ALWAYS invoke them with the `command` prefix (i.e. `command fd` / `command rg`) to bypass the alias and get clean, parseable output.

Fallback: if the modern tool isn't installed (`command -v fd` / `command -v rg` fails), fall back to the default `find` / `grep`. Prefer a guarded one-liner,
e.g. `command -v fd >/dev/null && command fd PATTERN || command find . -name PATTERN` and `command -v rg >/dev/null && command rg PATTERN || command grep -rn PATTERN`.

## 3.2. bypass color-injecting aliases

When running Linux commands via Shell, any command I (marslo) have aliased that injects ANSI color or changes behavior MUST be invoked with the `command` prefix (the raw binary) to get clean, parseable output.
Rule of thumb: if a command's output will be parsed again (pipes, command substitution, downstream grep/awk/sed), use `command` to bypass the alias. Purely human-facing interactive output may keep the colored alias.
Known aliases to bypass:

- `grep` / `egrep` / `lgrep` (aliased with `--color=always` plus `-i`/`-n`, which change both color and matching) → use `command grep` / `command egrep`
- `cat` → use `command cat`
- `ls` / `l` / `ll` / `l.` / `ld` (`--color=always`) → use `command ls`
- `rg` (`--color=always`) → use `command rg`, or pass `--color=never`
- `fd` (`--color=always`) → use `command fd`, or pass `--color=never`
- `diff` (`--color=auto`) → in pipes use `command diff`
- `eza` family (`la` / `els` / `etree`, `--icons` forces color) → when parsing use `command ls`
- `ip` (`ip -c`) → use `command ip`

## 3.3. Git - always bypass the external diff tool

My git is configured with an external/pager diff tool (e.g. difftastic / delta via `diff.external` or `[pager] diff`). Any command that emits a diff MUST be run with `--no-ext-diff` so the output is a clean, parseable unified diff:

- `git diff` → `git diff --no-ext-diff`
- `git show` → `git show --no-ext-diff`
- `git log -p` → `git log -p --no-ext-diff`

Add `--no-color` as well when the result will be parsed further.

@rules/bash-style.md
@rules/python-style.md
@rules/groovy-implicit-return.md
@rules/markdown-style.md
