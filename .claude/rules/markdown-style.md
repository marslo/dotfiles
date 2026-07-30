# Markdown Style

> Mirror of `~/.cursor/rules/markdown-style.mdc` (Cursor scope `globs: **/*.md`).
> Claude Code loads this globally — apply it when writing or editing Markdown.

Concise, scannable Markdown. Describe **what / how**; skip **why / rationale**.

## Rules

- **What & how, not why.** State the result / step / key point. Drop background and rationale. Only if the logic is genuinely complex, add 1–2 lines of explanation — no more.
- **Results / focus only.** No narration, no filler, no restating the obvious.
- **Prefer tables / code / lists over prose.** If a table or code block conveys it, don't write a paragraph.
- **Comment code sparingly.** Add short inline comments only where a snippet isn't self-evident; keep them terse.
- **Use GitHub callouts** for emphasis / tips / references — not bold prose (**files only**, **never in use chat/agent/assistant replies**). :

  | callout | use for |
  |---|---|
  | `> [!NOTE]` | context / reference |
  | `> [!TIP]` | optional advice |
  | `> [!IMPORTANT]` | must-know |
  | `> [!WARNING]` | gotcha / risk |
  | `> [!CAUTION]` | danger / data loss |

  Scope — **files only**: use callouts **only** when writing or editing an actual Markdown document/file (`*.md`, README, docs, etc.). In chat / assistant replies, **never** use `> [!NOTE]` / `> [!TIP]` etc. — even though the reply is rendered as Markdown, callout syntax is for files, not conversation.

## Prefer

```diff
- Because the cache can grow without bound on long-running hosts and eventually
- cause memory pressure, you should periodically call `.clear()`, which frees the
- backing store so that ...
+ Call `.clear()` periodically to cap memory.
```

> [!TIP]
> One idea per line. If you're explaining *why*, cut it.
