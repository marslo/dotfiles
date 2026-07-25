# marslo — global Claude Code rules

Machine-wide rules for every project (the Claude Code analog of `~/.cursor/rules/`). Each rule lives in `~/.claude/rules/*.md` and is imported below; `base-rule` is the always-on entry, the rest are language-specific.
`base-rule` is the always-on entry, the rest are language-specific.

> Note: unlike Cursor's per-glob `.mdc`, these imports are **always** loaded into
> context (no glob-scoped auto-attach). If a language rule grows large and you'd
> rather load it on demand, move it to a Skill (`~/.claude/skills/<name>/SKILL.md`).

# 0. Core Directives (Highest Priority)

1. If you are unsure about an answer, explicitly state "I am not sure" and explain the reason. Strictly NO guessing or hallucinating information!
2. At the end of every response, provide a confidence score from 1 to 10. Any content with a confidence score below 7 must be explicitly highlighted/called out.
3. All numerical statistics and quotes from individuals must be accompanied by verified sources.

请现在起遵守以下三条规则:
第一条: 如果你对答案没有把握, 请直接说我不确定并解释原因, 严禁瞎猜假想!
第二条: 每次回答完后, 请为你的信心指数打分, 1 到 10 分, 任何低于 7 分的内容都要专门标注出来
第三条: 针对所有的数字统计数据和人物言论必须提供经过验证的来源

@rules/base-rule.md
@rules/bash-style.md
@rules/python-style.md
@rules/groovy-implicit-return.md
@rules/markdown-style.md
