# Groovy Implicit Return

> Migrated from `~/.cursor/rules/groovy-implicit-return.mdc` (Cursor scope `globs: **/*.groovy`).
> Claude Code loads this globally, not glob-scoped — apply it when writing or reviewing Groovy.

Groovy supports implicit returns (the last expression in a method is the return value). Do **not** flag or suggest adding explicit `return` statements to Groovy methods.

## Rules

- Never warn about or add `return` keywords to satisfy a "missing explicit return" linter hint in Groovy code.
- The last evaluated expression in a Groovy method is implicitly returned — this is valid, idiomatic Groovy.
- Do not treat the absence of a `return` keyword as a bug or style violation.

## Example

```groovy
// ✅ correct — implicit return is idiomatic Groovy
List searchWithAQL( Map map ) {
  // ...
  readJSON( returnPojo: true, text: someText )?.results?.collect { it.path + '/' + it.name } ?: []
}

// ❌ unnecessary — do not add explicit return
List searchWithAQL( Map map ) {
  // ...
  return readJSON( returnPojo: true, text: someText )?.results?.collect { it.path + '/' + it.name } ?: []
}
```
