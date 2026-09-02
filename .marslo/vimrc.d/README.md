
> [!TIP]
> leader = `,` &nbsp;&nbsp;|&nbsp;&nbsp; localleader = `\`

---

# summary

| CATEGORY  | PLUGINS |
|-----------|---------|
| Common    | 55      |
| NVIM only | 18      |
| VIM only  | 1       |
| **Total** | **74**  |

## folder structure
```bash
vimrc.d/
├── autocmd                              # filetype autocmds (sh, python, markdown, etc.)
├── cmds                                 # custom commands and command abbreviations
├── devicons                             # vim-devicons icon mappings per filetype
├── extension                            # plugin configs and keymaps (fzf, coc, ale, etc.)
├── extra-extension                      # additional plugin configs (tagbar, table-mode, etc.)
├── functions                            # utility functions (TabMessage, GetPlug, etc.)
├── highlight                            # custom highlight groups and color overrides
├── os                                   # OS detection helpers (IsLinux, IsMac, IsWSL, etc.)
├── settings                             # general vim options (indent, fold, encoding, etc.)
├── shortcuts                            # key mappings and command abbreviations
├── snips/                               # coc-snippets files (*.snippets)
├── theme                                # colorscheme, airline, and UI settings
└── unix                                 # unix-specific redraw and clipboard settings
```

---

# table of content

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [General (built-in remaps)](#general-built-in-remaps)
    - [Insert Mode Helpers](#insert-mode-helpers)
    - [Text Manipulation](#text-manipulation)
- [vimrc - shortcuts and extensions](#vimrc---shortcuts-and-extensions)
  - [Common](#common)
    - [tpope/vim-surround](#tpopevim-surround)
    - [godlygeek/tabular](#godlygeektabular)
    - [junegunn/fzf.vim](#junegunnfzfvim)
    - [preservim/tagbar](#preservimtagbar)
    - [scrooloose/nerdtree](#scrooloosenerdtree)
    - [simnalamburt/vim-mundo](#simnalamburtvim-mundo)
    - [yegappan/mru](#yegappanmru)
    - [marslo/authorinfo](#marsloauthorinfo)
    - [tomtom/tcomment_vim](#tomtomtcomment_vim)
    - [dhruvasagar/vim-table-mode](#dhruvasagarvim-table-mode)
    - [Konfekt/FastFold](#konfektfastfold)
    - [neoclide/coc.nvim](#neoclidecocnvim)
    - [Groovy / Jenkinsfile documentation (javadoc + go-to-definition)](#groovy--jenkinsfile-documentation-javadoc--go-to-definition)
    - [dense-analysis/ale](#dense-analysisale)
    - [airblade/vim-gitgutter](#airbladevim-gitgutter)
    - [zivyangll/git-blame.vim](#zivyangllgit-blamevim)
    - [APZelos/blamer.nvim](#apzelosblamernvim)
    - [Git Custom Shortcuts](#git-custom-shortcuts)
    - [LunarWatcher/auto-pairs](#lunarwatcherauto-pairs)
    - [iamcco/markdown-preview.nvim](#iamccomarkdown-previewnvim)
    - [Shell Script (autocmd)](#shell-script-autocmd)
    - [Python (autocmd)](#python-autocmd)
    - [Markdown (autocmd)](#markdown-autocmd)
  - [NVIM ONLY](#nvim-only)
    - [stevearc/oil.nvim](#stevearcoilnvim)
    - [zbirenbaum/copilot.lua](#zbirenbaumcopilotlua)
    - [hrsh7th/nvim-cmp](#hrsh7thnvim-cmp)
    - [nvim-treesitter/nvim-treesitter-textobjects](#nvim-treesitternvim-treesitter-textobjects)
  - [VIM ONLY](#vim-only)
    - [github/copilot.vim](#githubcopilotvim)
  - [Others Plugins](#others-plugins)
    - [NVIM ONLY](#nvim-only-1)
- [vimrc - commands](#vimrc---commands)
  - [Command Abbreviations](#command-abbreviations)
- [lexima behavior reference](#lexima-behavior-reference)
  - [1. Basic pairing — cursor is followed by an "allowed position"](#1-basic-pairing--cursor-is-followed-by-an-allowed-position)
  - [2. Pairing suppressed — cursor is followed by a word char / `.` / `@` etc. (not an allowed position)](#2-pairing-suppressed--cursor-is-followed-by-a-word-char-----etc-not-an-allowed-position)
  - [3. Apostrophe in contractions/words — `'` right after a word](#3-apostrophe-in-contractionswords---right-after-a-word)
  - [4. Skip over the closing char (leave-over) — cursor already before the closing char](#4-skip-over-the-closing-char-leave-over--cursor-already-before-the-closing-char)
  - [5. `<<` (second `<`)](#5--second-)
  - [6. After the escape char `\`](#6-after-the-escape-char-%5C)
  - [7. Triple quotes (markdown / docstring)](#7-triple-quotes-markdown--docstring)
  - [8. Backspace deletes the whole pair](#8-backspace-deletes-the-whole-pair)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

# General (built-in remaps)

> [!NOTE]
> source:
> - [shortcuts](shortcuts)
> - [functions](functions)
> - [cmds](cmds)

| SHORTCUT    | MODE  | COMMENTS                                     |
|-------------|-------|----------------------------------------------|
| `,i`        | n     | `:Inspect` treesitter highlight              |
| `,v`        | n     | edit `~/.vimrc`                              |
| `,Q`        | n     | `:qa!` - quit all force                      |
| `,bd`       | n     | `:bd` - delete current buffer                |
| `,bp`       | n     | next buffer (skip quickfix)                  |
| `,bn`       | n     | previous buffer (skip quickfix)              |
| `,sv`       | n     | source `$MYVIMRC` and reload config          |
| `,mm`       | n     | toggle mouse on/off                          |
| `,pp`       | n     | toggle paste mode                            |
|             |       |                                              |
| `j` / `k`   | n     | move by display line (`gj`/`gk`)             |
| `gj` / `gk` | n     | move by real line                            |
| `n` / `N`   | n     | search next/prev and center + open fold      |
|             |       |                                              |
| `*`         | x     | visual search forward                        |
| `#`         | x     | visual search backward                       |
| `~`         | v     | twiddle case (lower → Title → UPPER → lower) |
| `&`         | n/x   | repeat last substitute                       |
| `s`         | v     | surround (VSurround)                         |
| `Y`         | n     | yank to end of line (`y$`)                   |
| `//`        | v     | search for visual selection                  |
|             |       |                                              |
| `qQ`        | n     | `:%bd` - delete all buffers                  |
| `rdd`       | n     | delete line without yanking                  |
| `rdw`       | n     | delete word without yanking                  |
| `sx`        | n     | delete char without yanking                  |
| `sd`        | v     | delete selection without yanking             |
| `zzf`       | n     | fold around visual block (`vazzO`)           |
|             |       |                                              |
| `<C-k>`     | n     | `<C-w>k` - move to upper window              |
| `<C-j>`     | n     | `<C-w>j` - move to lower window              |
| `<C-h>`     | n     | `<C-w>h` - move to left window               |
| `<C-a>`     | n/i/c | go to beginning of line                      |
| `<C-e>`     | n/i/c | go to end of line                            |
| `<C-k>`     | c     | kill to end of cmdline                       |
| `<M-m>`     | n     | toggle mouse model (extend / popup_setpos)   |
| `<Del>`     | n/x   | delete without yanking                       |
| `<space>`   | n     | toggle fold (`za`)                           |
| `<Esc>`     | t     | exit terminal mode                           |
| `<C-w>`     | t     | window command in terminal mode              |
| `<S-Tab>`   | n     | switch to next buffer (skip quickfix)        |
| `<F10>`     | n     | echo syntax highlight group at cursor        |
| `<F12>`     | n     | update ctags                                 |

### Insert Mode Helpers

| SHORTCUT | MODE | COMMENTS                                       |
|----------|------|------------------------------------------------|
| `,tt`    | i    | insert current timestamp `YYYY-MM-DD HH:MM:SS` |
| `,fn`    | i    | insert filename without extension              |
| `,fe`    | i    | insert filename with extension                 |
| `,w`     | i    | save file in insert mode                       |

### Text Manipulation

| SHORTCUT             | MODE | COMMENTS                                      |
|----------------------|------|-----------------------------------------------|
| `,r`                 | n/x  | reverse lines (`:Reverse`)                    |
| `,*` / `,G` / `,zwl` | n    | count pattern matches in file                 |
| `,zil`               | n    | insert line numbers at beginning of each line |
| `,zcm`               | n    | convert `^M` to newline                       |
| `,zdm`               | n    | delete `^M`                                   |
| `,zdb`               | n    | delete trailing whitespace                    |
| `,zd2`               | n    | delete `U+200B` (zero-width space)            |
| `,zdd`               | n    | delete non-breaking space (`0xA0`)            |
| `,zds`               | n    | delete `<span>` tags                          |
| `,zdi`               | n    | delete leading indent spaces                  |
| `,zid`               | n    | insert bullet `•` (`0x2022`)                  |
| `,fhl` / `,zhl`      | n    | format HTML (`>` → `>\n<`)                    |
| `,zbl`               | n    | delete blank lines                            |
| `,cr`                | n    | evaluate expression on current line           |

---

# vimrc - shortcuts and extensions

## Common

### [tpope/vim-surround](https://github.com/tpope/vim-surround)

| SHORTCUT           | MODE | COMMENTS                           |
|--------------------|------|------------------------------------|
| `s`                | v    | add surrounding (via `VSurround`)  |
| `cs<old><new>`     | n    | change surrounding from old to new |
| `ds<char>`         | n    | delete surrounding char            |
| `ys<motion><char>` | n    | add surrounding char around motion |

### [godlygeek/tabular](https://github.com/godlygeek/tabular)

| SHORTCUT | MODE | COMMENTS                          |
|----------|------|-----------------------------------|
| `,a=`    | n/v  | tabularize by `=`                 |
| `,a:`    | n/v  | tabularize by `:`                 |
| `\|`     | i    | auto-align table when typing `\|` |

### [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)

| SHORTCUT     | MODE | COMMENTS                                |
|--------------|------|-----------------------------------------|
| `,ff`        | n    | `:Files` - fuzzy find files             |
| `,gf`        | n    | `:GFiles` - git files                   |
| `,ag`        | n    | `:Ag` - silver searcher                 |
| `,l`         | n    | `:Buffers` - list buffers               |
| `,H`         | n    | `:Helptags` - search help tags          |
| `,g`         | n    | `:Commits` - git commits                |
| `,hh`        | n    | `:History:` - command history           |
|              |      |                                         |
| `<C-x><C-k>` | i    | complete from dictionary                |
| `<C-x><C-l>` | i    | fuzzy complete line from all files (rg) |
| `<C-t>`      | fzf  | open in new tab                         |
| `<C-x>`      | fzf  | open in horizontal split                |
| `<C-v>`      | fzf  | open in vertical split                  |
| `Ctrl-\`     | fzf  | toggle preview window                   |

### [preservim/tagbar](https://github.com/preservim/tagbar)

| SHORTCUT | MODE | COMMENTS        |
|----------|------|-----------------|
| `,tb`    | n    | `:TagbarToggle` |

### [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)

| SHORTCUT  | MODE | COMMENTS                                   |
|-----------|------|--------------------------------------------|
| `<C-A-n>` | n    | `:NERDTreeToggle` (Ctrl+Option+n on macOS) |
| `,nt`     | n    | `:NERDTreeToggle`                          |

### [simnalamburt/vim-mundo](https://github.com/simnalamburt/vim-mundo)

| SHORTCUT | MODE | COMMENTS                   |
|----------|------|----------------------------|
| `,u`     | n    | `:MundoToggle` - undo tree |

### [yegappan/mru](https://github.com/yegappan/mru)

| SHORTCUT | MODE | COMMENTS                          |
|----------|------|-----------------------------------|
| `,re`    | n    | `:MRU` - most recently used files |

### [marslo/authorinfo](https://github.com/marslo/authorinfo)

| SHORTCUT | MODE | COMMENTS            |
|----------|------|---------------------|
| `,aid`   | n    | `:AuthorInfoDetect` |

### [tomtom/tcomment_vim](https://github.com/tomtom/tcomment_vim)

| SHORTCUT | MODE | COMMENTS                 |
|----------|------|--------------------------|
| `,x`     | n    | toggle comment (`gcc`)   |
| `,x`     | v    | `:TComment` on selection |
|          |      |                          |
| `<C-/>`  | n    | toggle comment (`gcc`)   |
| `<C-/>`  | i    | `:TComment`              |
| `<C-/>`  | v    | `:TCommentBlock`         |

### dhruvasagar/vim-table-mode

| SHORTCUT | MODE | COMMENTS           |
|----------|------|--------------------|
| `,tm`    | n    | `:TableModeToggle` |

### [Konfekt/FastFold](https://github.com/Konfekt/FastFold)

| SHORTCUT | MODE | COMMENTS           |
|----------|------|--------------------|
| `zuz`    | n    | `FastFoldUpdate`   |
| `,iz`    | x    | select inside fold |
| `,az`    | x    | select around fold |

### [neoclide/coc.nvim](https://github.com/neoclide/coc.nvim)

> [!TIP]
> disabled in vscode/cursor

| SHORTCUT             | MODE | COMMENTS                                          | FROM                       |
| -------------------- | ---- | ------------------------------------------------- | -------------------------- |
| `,cl`                | n    | `coc-codelens-action`                             | -                          |
| `,ac`                | n    | `coc-codeaction-cursor`                           | -                          |
| `,as`                | n    | `coc-codeaction-source`                           | -                          |
| `,aa`                | n/x  | `coc-codeaction-selected`                         | -                          |
| `,qf`                | n/x  | `coc-fix-current` (n) / quickfix in selection (x) | -                          |
|                      |      |                                                   |                            |
| `[g`                 | n    | `coc-diagnostic-prev`                             | -                          |
| `]g`                 | n    | `coc-diagnostic-next`                             | -                          |
| `gd`                 | n    | `coc-definition`                                  | -                          |
| `gy`                 | n    | `coc-type-definition`                             | -                          |
| `gi`                 | n    | `coc-implementation`                              | -                          |
| `gr`                 | n    | `coc-references`                                  | -                          |
| `K`                  | n    | show documentation (hover)                        | -                          |
| `<M-h>`              | n    | toggle idle auto-hover on/off                     | `autoload/groovy_tags.vim` |
|                      |      |                                                   |                            |
| `<C-S-j>`            | i    | `coc-snippets-expand`                             | -                          |
| `<C-j>`              | v    | `coc-snippets-select`                             | -                          |
| `<C-j>`              | i    | snippet expand or jump                            | -                          |
| `<C-k>`              | -    | snippet prev (via `coc_snippet_prev`)             | -                          |
| `<DOWN>`             | i    | coc popup next item                               | -                          |
| `<UP>`               | i    | coc popup prev item                               | -                          |
| `<C-M>`              | i    | coc popup confirm                                 | -                          |
|                      |      |                                                   |                            |
| `:OR`                | cmd  | organize imports                                  | -                          |
| `:GroovyHoverToggle` | cmd  | toggle idle auto-hover on/off                     | `autoload/groovy_tags.vim` |

#### coc-html — external typescript dependency

> [!IMPORTANT]
> `coc-html` needs a matching `typescript` that coc does **not** auto-install, so its language server crashes on start:
> - `Cannot find module 'typescript'` — none installed
> - `Cannot read properties of undefined (reading 'JS')` — wrong major (e.g. global TS 7 against coc-html 1.9.0)
>
> Version map: `coc-html` 1.7.0/1.8.0 → `typescript@^4.3`; 1.9.0 → `typescript@^6.0.3` (npm has only 6.0.2 / 6.0.3). Adding `typescript` to `g:coc_global_extensions` does **not** work (coc rejects packages without an `engines.coc` field). `coc-tsserver` bundles its own TS, invisible to `coc-html`.

`require('typescript')` walks `node_modules` up from the file, then `NODE_PATH`; it never searches the global npm dir on its own (PATH only helps CLI binaries). Two fixes:

```bash
# 1) local — keeps global TS 7 for other tools (coc-html uses 6.x from extensions/node_modules)
cd ~/.config/coc/extensions && npm install typescript@6
npm install -g typescript@7

# 2) global — simplest; global tsc becomes 6.x too
npm install -g typescript@6
export NODE_PATH="/opt/homebrew/lib/node_modules"   # = `npm root -g`; so coc-html can require it
```

> [!TIP]
> Most robust (survives coc extension updates): a dedicated dir `~/.config/coc/ts6` with `typescript@6.0.3` + `export NODE_PATH="$HOME/.config/coc/ts6/node_modules"` — coc never prunes it, unlike `extensions/node_modules`. Run `:CocRestart` after any fix.

### Groovy / Jenkinsfile documentation (javadoc + go-to-definition)

> [!NOTE]
> [setup environment](https://github.com/marslo/mytools/tree/main/itool):
> ```bash
> curl -fsSL https://github.com/marslo/mytools/raw/main/itool/groovy-libs.sh  | bash -s -- --groovy --with-libs --path /opt/groovy
> curl -fsSL https://github.com/marslo/mytools/raw/main/itool/jenkins-libs.sh | bash -s -- --lts --ln --sources --javadoc --path /opt/jenkins
> curl -fsSL https://github.com/marslo/dotfiles/raw/main/.marslo/bin/lsp-gdoc | bash -s -- --build
> ```
> ```vim
> " ~/.vimrc
> augroup Groovy
>   autocmd!
>   autocmd FileType groovy,Jenkinsfile setlocal tags+=~/.cache/nvim/gdoc/.tags
> augroup END
> augroup JavaMarkdownDoc
>   autocmd!
>   autocmd ColorScheme * highlight default link markdownLineStart markdownH1
> augroup END
> silent! highlight default link markdownLineStart markdownH1
> ```

| SHORTCUT     | MODE | COMMENTS                                                                               |
| ------------ | ---- | -------------------------------------------------------------------------------------- |
| `,gd`        | n    | `gdoc#hover()` — javadoc for the symbol under the cursor (from `-sources.jar`); nvim   |
| `<C-]>`      | n    | go to definition — in groovy/Jenkinsfile also jumps into the extracted jar sources     |
| `<C-t>`      | n    | jump back after `<C-]>`                                                                |
| `gh.<meth>`  | i    | in Jenkinsfile, `.` completion shows the shared-lib javadoc (`[GT]` source)            |
| `:GdocBuild` | cmd  | (re)build the offline index — `lsp-gdoc --build`; nvim                                 |
| `K`          | n    | `groovy_tags#hover()` — doc for the lib call under the cursor; falls back to coc hover |
| `gd`         | n    | `groovy_tags#definition()` — arity-aware go-to-def for `lib.member` / same-file calls  |
| `<M-h>`      | n    | toggle idle auto-hover on/off (also `:GroovyHoverToggle`)                              |

- `<C-]>` into jar sources works via a **buffer-local** `tags+=~/.cache/nvim/gdoc/.tags`, set only for `groovy`/`Jenkinsfile`
- `libs.<method>` completion + javadoc comes from the `groovy_tags` coc source, which reads the repo `.tags` (via `gctags`) and extracts the `/** */` block above the def in `vars/*.groovy`.
- rebuild after downloading new jars: `lsp-gdoc --build` (or `:GdocBuild`).

#### the autoload files behind groovy-lib docs

| file                                  | how to call                                    | keys / trigger             | what to provide                                                                               | source                                                                                              |
| ------------------------------------- | ---------------------------------------------- | -------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `autoload/coc/source/groovy_tags.vim` | `coc#source#groovy_tags#init` / `#complete`    | `.` (insert)               | `lib.member` completion + javadoc preview (`[GT]` source)                                     | repo-root `.tags` (via `gctags`, over `vars/*.groovy` + `jenkinsfile/`)                             |
| `autoload/groovy_tags.vim`            | `groovy_tags#hover` / `#definition` / `#setup` | `K`, `gd`, idle auto-hover | hover, arity-aware go-to-definition, and idle auto-hover for `lib.member` and same-file calls | repo-root `.tags` (+ the live buffer for same-file calls)                                           |
| `autoload/gdoc.vim`                   | `gdoc#hover` / `gdoc#build`                    | `,gd`, `:GdocBuild`        | javadoc hover for classpath symbols; (re)builds the offline index                             | `~/.cache/nvim/gdoc/` — `.tags`, `src/`, `javadoc-map.tsv` (from `*-sources.jar` / `*-javadoc.jar`) |

- the two `groovy_tags.vim` files share a base name **by choice** (same feature family), not by requirement — separate namespaces (`coc#source#groovy_tags#*` vs `groovy_tags#*`), and neither calls the other.
- `groovy_tags` (repo `.tags`) covers your `vars/*.groovy` libs; `gdoc` (classpath index) covers symbols from jars — two indexes, kept independent. `groovy_tags` explicitly skips the `~/.cache/nvim/gdoc/` tag file so it never scans the 88MB classpath index.
- the gdoc classpath index is consumed by `,gd` (`gdoc#hover`), `<C-]>` (native jump into jar sources), and coc's generic `[Tag]` source — **not** by the `[GT]` source above (which reads only repo `.tags`). two separate completion sources: `[GT]` = your libs, `[Tag]` = all `&tags` incl. classpath.
- `<C-]>` is **not** any of these files — it is vim's native tag jump over `&tags`; `gd` (groovy_tags) is arity-aware, `<C-]>` is not.
- config (both live, no reload): `g:groovy_tags_auto_hover` — on/off (`1/0`, `yes/no`, `true/false`, `on/off`); `g:groovy_tags_auto_hover_delay` — idle delay in ms, unset → follow `&updatetime`.

### [dense-analysis/ale](https://github.com/dense-analysis/ale)

| SHORTCUT | MODE | COMMENTS           |
|----------|------|--------------------|
| `]a`     | n    | `:ALENextWrap`     |
| `[a`     | n    | `:ALEPreviousWrap` |
| `]A`     | n    | `:ALELast`         |
| `[A`     | n    | `:ALEFirst`        |
| `]d`     | n    | `:ALEDetail`       |
| `[d`     | n    | `:ALEDetail`       |

### [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)

| SHORTCUT | MODE | COMMENTS          |
|----------|------|-------------------|
| `]h`     | n    | next git hunk     |
| `[h`     | n    | previous git hunk |

### [zivyangll/git-blame.vim](https://github.com/zivyangll/git-blame.vim)

| SHORTCUT | MODE | COMMENTS                        |
|----------|------|---------------------------------|
| `,ebb`   | n    | echo git blame for current line |

### [APZelos/blamer.nvim](https://github.com/APZelos/blamer.nvim)

| SHORTCUT | MODE | COMMENTS                           |
|----------|------|------------------------------------|
| `,bb`    | n    | `:BlamerToggle` - inline git blame |

### Git Custom Shortcuts

| SHORTCUT | MODE | COMMENTS                           |
|----------|------|------------------------------------|
| `,mp`    | n    | `git mp` - commit changes          |
| `,pmp`   | n    | `git mp -r` - force commit changes |

### [LunarWatcher/auto-pairs](https://github.com/LunarWatcher/auto-pairs)

| SHORTCUT | MODE | COMMENTS                 |
|----------|------|--------------------------|
| `<M-p>`  | -    | auto-pairs prefix        |
| `<M-j>`  | -    | toggle auto-pairs        |
| `<M-n>`  | -    | jump to next closed pair |
| `<M-b>`  | -    | back insert              |

### [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

| SHORTCUT          | MODE | COMMENTS                      |
|-------------------|------|-------------------------------|
| `<F5>` (markdown) | n    | open in Google Chrome (macOS) |

### Shell Script (autocmd)

| SHORTCUT | MODE   | COMMENTS                         |
|----------|--------|----------------------------------|
| `]]`     | n (sh) | jump to next function definition |
| `[[`     | n (sh) | jump to prev function definition |

### Python (autocmd)

| SHORTCUT | MODE       | COMMENTS                             |
|----------|------------|--------------------------------------|
| `<F9>`   | n (python) | run current file with python3        |
| `<F9>`   | i (python) | save & run current file with python3 |

### Markdown (autocmd)

| SHORTCUT | MODE         | COMMENTS                        |
|----------|--------------|---------------------------------|
| `[%`     | n (markdown) | jump to prev code fence ` ``` ` |
| `]%`     | n (markdown) | jump to next code fence ` ``` ` |

---

## NVIM ONLY

### [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim)

| SHORTCUT | MODE | COMMENTS                         |
|----------|------|----------------------------------|
| `,-`     | n    | Oil float - parent directory     |
| `,_`     | n    | Oil float - project root (`.`)   |
| `,~`     | n    | Oil float - home directory (`~`) |
| `q`      | oil  | close oil window                 |
| `u`      | oil  | navigate to parent directory     |

### [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua)

| SHORTCUT  | MODE | COMMENTS                                    |
|-----------|------|---------------------------------------------|
| `<Tab>`   | i    | accept suggestion (Copilot > LuaSnip > Tab) |
| `<S-Tab>` | i    | LuaSnip jump back / shift-tab               |
| `<C-l>`   | i    | accept copilot word                         |
| `<C-M-l>` | i    | accept copilot line                         |
| `<M-]>`   | i    | next copilot suggestion                     |
| `<M-[>`   | i    | prev copilot suggestion                     |
| `<C-]>`   | i    | dismiss copilot suggestion                  |
| `<F2>`    | n    | toggle copilot enable/disable               |

#### Copilot Panel

| SHORTCUT | MODE  | COMMENTS                |
|----------|-------|-------------------------|
| `<M-p>`  | -     | open copilot panel      |
| `<CR>`   | panel | accept suggestion       |
| `[[`     | panel | jump to prev suggestion |
| `]]`     | panel | jump to next suggestion |
| `gr`     | panel | refresh                 |

### [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

> command-line completion only (insert mode handled by coc)

| SHORTCUT             | MODE | COMMENTS                  |
|----------------------|------|---------------------------|
| `<C-p>` / `<C-n>`   | c    | navigate completion items |
| `<Tab>` / `<S-Tab>`  | c    | navigate completion items |
| `<Up>` / `<Down>`    | c    | history navigation        |

### [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)

#### Text Object Selection

| SHORTCUT      | MODE | COMMENTS                |
|---------------|------|-------------------------|
| `af` / `if`   | x/o  | outer / inner function  |
| `ac` / `ic`   | x/o  | outer / inner class     |
| `aa` / `ia`   | x/o  | outer / inner parameter |
| `agc` / `igc` | x/o  | outer / inner comment   |

#### Move Between Functions/Classes

| SHORTCUT    | MODE  | COMMENTS                   |
|-------------|-------|----------------------------|
| `]m` / `[m` | n/x/o | next / prev function start |
| `]M` / `[M` | n/x/o | next / prev function end   |
| `]]` / `[[` | n/x/o | next / prev class start    |
| `][` / `[]` | n/x/o | next / prev class end      |

#### Swap Parameters

| SHORTCUT | MODE | COMMENTS                         |
|----------|------|----------------------------------|
| `,a`     | n    | swap current param with next     |
| `,A`     | n    | swap current param with previous |

#### Repeatable Moves

| SHORTCUT              | MODE  | COMMENTS                                      |
|-----------------------|-------|-----------------------------------------------|
| `;`                   | n/x/o | repeat last move (same direction)             |
| `,`                   | n/x/o | repeat last move (opposite direction)         |
| `f` / `F` / `t` / `T` | n/x/o | builtin motions (repeatable with `;` and `,`) |

---

## VIM ONLY

### [github/copilot.vim](https://github.com/github/copilot.vim)

| SHORTCUT  | MODE | COMMENTS            |
|-----------|------|---------------------|
| `<F2>`    | n    | `:Copilot disable`  |
| `<C-L>`   | i    | accept copilot word |
| `<C-M-L>` | i    | accept copilot line |

---

## Others Plugins

| PLUGIN                                                                                                | COMMENTS                                                     |
|-------------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| [tpope/vim-repeat](https://github.com/tpope/vim-repeat)                                               | `.` repeat support for plugin mappings                       |
| [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)                                           | Git wrapper — `:Git blame`, `:Git diff`, `:Gdiffsplit`, etc. |
| [tpope/vim-git](https://github.com/tpope/vim-git)                                                     | Git filetype plugins (commit, rebase, etc.)                  |
| [junegunn/gv.vim](https://github.com/junegunn/gv.vim)                                                 | Git commit browser — `:GV`                                   |
| [andymass/vim-matchup](https://github.com/andymass/vim-matchup)                                       | enhanced `%` matching; shows matching pair in popup          |
| [luochen1990/rainbow](https://github.com/luochen1990/rainbow)                                         | rainbow parentheses (auto-enabled)                           |
| [Yggdroot/indentLine](https://github.com/Yggdroot/indentLine)                                         | indent guides with `¦` character (auto-enabled)              |
| [rrethy/vim-hexokinase](https://github.com/rrethy/vim-hexokinase)                                     | inline color preview (hex, rgb, hsl, color names)            |
| [preservim/vim-markdown](https://github.com/preservim/vim-markdown)                                   | markdown syntax, folding, concealing                         |
| [vim-autoformat/vim-autoformat](https://github.com/vim-autoformat/vim-autoformat)                     | auto format code on demand                                   |
| [dstein64/vim-startuptime](https://github.com/dstein64/vim-startuptime)                               | profile vim startup time via `:StartupTime`                  |
| [rizzatti/dash.vim](https://github.com/rizzatti/dash.vim)                                             | search Dash.app documentation                                |
| [dbeniamine/cheat.sh-vim](https://github.com/dbeniamine/cheat.sh-vim)                                 | query cheat.sh from vim                                      |
| [fracpete/vim-large-files](https://github.com/fracpete/vim-large-files)                               | disable features for large files (performance)               |
| [kana/vim-textobj-user](https://github.com/kana/vim-textobj-user)                                     | framework for custom text objects                            |
| [kana/vim-textobj-fold](https://github.com/kana/vim-textobj-fold)                                     | text object for folds (`iz`, `az`)                           |
| [honza/vim-snippets](https://github.com/honza/vim-snippets)                                           | community-maintained snippet collection                      |
| [tomtom/tlib_vim](https://github.com/tomtom/tlib_vim)                                                 | utility library for vim plugins                              |
| [amadeus/vim-css](https://github.com/amadeus/vim-css)                                                 | improved CSS syntax highlighting                             |
| [parkr/vim-jekyll](https://github.com/parkr/vim-jekyll)                                               | Jekyll (GitHub Pages) support                                |
| [marslo/vim-devicons](https://github.com/marslo/vim-devicons)                                         | file-type glyphs/icons for NERDTree, airline, etc.           |
| [marslo/MarsloFunc](https://github.com/marslo/MarsloFunc)                                             | custom utility functions (`marslofunc#`)                     |
| [marslo/marslo.vim](https://github.com/marslo/marslo.vim)                                             | colorscheme for `t_Co=16` terminals                          |
| [tiagofumo/vim-nerdtree-syntax-highlight](https://github.com/tiagofumo/vim-nerdtree-syntax-highlight) | file-type highlighting for NERDTree                          |
| [vim-airline/vim-airline](https://github.com/vim-airline/vim-airline)                                 | statusline & tabline (disabled in vscode/cursor)             |
| [vim-airline/vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)                   | airline theme collection (`base16_embers`)                   |
| [sheerun/vim-polyglot](https://github.com/sheerun/vim-polyglot)                                       | language pack collection for syntax highlighting             |
| [pearofducks/ansible-vim](https://github.com/pearofducks/ansible-vim)                                 | Ansible YAML syntax & filetype detection                     |
| [stephpy/vim-yaml](https://github.com/stephpy/vim-yaml)                                               | YAML syntax highlighting                                     |
| [pedrohdz/vim-yaml-folds](https://github.com/pedrohdz/vim-yaml-folds)                                 | YAML indent-based folding                                    |
| [ekalinin/Dockerfile.vim](https://github.com/ekalinin/Dockerfile.vim)                                 | Dockerfile syntax highlighting                               |
| [morhetz/gruvbox](https://github.com/morhetz/gruvbox)                                                 | gruvbox colorscheme                                          |
| [sainnhe/gruvbox-material](https://github.com/sainnhe/gruvbox-material)                               | gruvbox-material colorscheme (default for local)             |
| [luisiacc/gruvbox-baby](https://github.com/luisiacc/gruvbox-baby)                                     | gruvbox-baby colorscheme variant                             |
| [sainnhe/everforest](https://github.com/sainnhe/everforest)                                           | everforest colorscheme (default for SSH)                     |
| [xu-cheng/brew.vim](https://github.com/xu-cheng/brew.vim)                                             | Homebrew formula syntax (macOS only)                         |
| [machakann/vim-highlightedyank](https://github.com/machakann/vim-highlightedyank)                     | highlight yanked region (vim only, nvim built-in)            |

### NVIM ONLY

| PLUGIN                                                                                | COMMENTS                                                  |
|---------------------------------------------------------------------------------------|-----------------------------------------------------------|
| [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua)                               | fzf integration; `vim.ui.select` backend                  |
| [CopilotC-Nvim/CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim)   | `:CopilotChat` for interactive AI chat                    |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)                               | snippet engine; `<Tab>`/`<S-Tab>` via copilot.lua routing |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)       | community snippet collection for LuaSnip                  |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | syntax highlighting & code parsing via tree-sitter        |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)                   | async linting engine                                      |
| [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)                     | utility library for nvim lua plugins                      |
| [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)         | file-type icons (lua, required by fzf-lua)                |
| [zbirenbaum/copilot-cmp](https://github.com/zbirenbaum/copilot-cmp)                   | copilot source for nvim-cmp                               |
| [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)                       | nvim-cmp LSP source                                       |
| [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)                           | nvim-cmp buffer source                                    |
| [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)                               | nvim-cmp path source                                      |
| [hrsh7th/cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline)                         | nvim-cmp cmdline source                                   |
| [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)               | nvim-cmp LuaSnip source                                   |

# vimrc - commands

> Custom commands defined in vimrc.d and nvim config (not built-in vim/nvim commands).

| COMMAND              | ARGS               | SOURCE                                                                              | COMMENTS                                                                    |
| -------------------- | ------------------ | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `:Reverse`           | `[range]`          | [cmds](./cmds)                                                                      | reverse lines in range (default: whole file)                                |
| `:Silent <cmd>`      | `<cmd>`            | [cmds](./cmds)                                                                      | execute shell command silently and redraw                                   |
| `:DocTocUpdate [n]`  | `[maxlevel]`       | [cmds](./cmds)                                                                      | update existing doctoc (default maxlevel=3)                                 |
| `:DocTocCreate [n]`  | `[maxlevel]`       | [cmds](./cmds)                                                                      | create new doctoc (default maxlevel=3)                                      |
| `:First <char>`      | `<char>` `[range]` | [cmds](./cmds)                                                                      | tabularize by first occurrence of char                                      |
| `:Iname`             | - or `-p`          | [cmds](./cmds)                                                                      | echo or paste absolute path of current file                                 |
| `:FormatJSON`        | `[range]`          | [cmds](./cmds)                                                                      | format JSON via `jq`                                                        |
| `:Hitest`            | -                  | [cmds](./cmds)                                                                      | echo syntax highlight stack at cursor                                       |
| `:FixSyntax`         | -                  | [cmds](./cmds)                                                                      | `syntax sync fromstart` to fix broken highlighting                          |
| `:TabMessage <cmd>`  | `<cmd>`            | [functions](./functions)                                                            | redirect ex-command output into a new tab                                   |
| `:GetPlug`           | -                  | [functions](./functions)                                                            | download vim-plug to `~/.vim/autoload/plug.vim`                             |
| `:GetVim`            | -                  | [functions](./functions)                                                            | `marslofunc#GetVim()` (requires MarsloFunc plugin)                          |
| `:PlugUpdateHTTPS`   | -                  | [functions](./functions)                                                            | PlugUpdate over HTTPS (bypass GnuPG SSH agent)                              |
| `:OR`                | -                  | [extension](./extension)                                                            | coc - organize imports                                                      |
| `:Files [dir]`       | `[dir]`            | [extension](./extension)                                                            | fzf files with bat preview (overrides fzf.vim)                              |
| `:LS [dir]`          | `[dir]`            | [extension](./extension)                                                            | fzf `ls` output in given directory                                          |
| `:GdocBuild`         | -                  | [shortcuts](./shortcuts)                                                            | rebuild offline javadoc index for groovy/javadoc hover (`lsp-gdoc --build`) |
| `:TSInstallAll`      | -                  | [lua/config/nvim-treesitter.lua](../../.config/nvim/lua/config/nvim-treesitter.lua) | install all configured treesitter parsers                                   |
| `:DebugCursor`       | -                  | [plugin/dynamic-cursor.lua](../../.config/nvim/plugin/dynamic-cursor.lua)           | print extmarks + treesitter captures at cursor                              |
| `:GroovyHoverToggle` | -                  | [autoload/groovy_tags.vim](../../.config/nvim/autoload/groovy_tags.vim)             | toggle idle auto-hover on/off for groovy/javadoc hover                      |

---

## Command Abbreviations

> [!NOTE]
> typo-proof abbreviations defined in [shortcuts](shortcuts)

| ABBREVIATION                    | REPLACEMENT                  |
|---------------------------------|------------------------------|
| `:W` / `:W!`                    | `:w` / `:w!`                 |
| `:Q` / `:Q!`                    | `:q` / `:q!`                 |
| `:X` / `:X!`                    | `:x` / `:x!`                 |
| `:XA` / `:Xa` / `:XA!` / `:Xa!` | `:xa` / `:xa!`               |
| `:WQ` / `:WQ!`                  | `:wq` / `:wq!`               |
| `:QA` / `:QA!`                  | `:qa` / `:qa!`               |
| `:WA` / `:WA!`                  | `:wa` / `:wa!`               |
| `:NOH` / `:Noh`                 | `:noh`                       |
| `:%Y`                           | `:%y`                        |
| `:%D`                           | `:%d`                        |
| `sudow!!`                       | `w !sudo tee > /dev/null %`  |
| `sw!!`                          | silent sudo write and reload |

# lexima behavior reference

> Cursor is shown as `│`. Rules come from the lexima config in [`.marslo/vimrc.d/extension`](https://github.com/marslo/dotfiles/blob/main/.marslo/vimrc.d/extension#L245-L311).
> "Allowed position" = space / end of line / `) ] } >` / `" ' ` `` ` `` / `/` / `, ; : ! ?`.

## 1. Basic pairing — cursor is followed by an "allowed position"

| BEFORE | INPUT   | AFTER     | NOTE                             |
| ------ | ------- | --------- | -------------------------------- |
| `│`    | `(`     | `(│)`     | paired                           |
| `│`    | `[`     | `[│]`     | paired                           |
| `│`    | `{`     | `{│}`     | paired                           |
| `│`    | `"`     | `"│"`     | paired                           |
| `│`    | `'`     | `'│'`     | paired                           |
| `│`    | `` ` `` | `` `│` `` | paired                           |
| `│`    | `<`     | `<│>`     | paired                           |
| `foo│` | `{`     | `foo{│}`  | cursor at end of line → allowed  |
| `│/x`  | `(`     | `(│)/x`   | cursor followed by `/` → allowed |

## 2. Pairing suppressed — cursor is followed by a word char / `.` / `@` etc. (not an allowed position)

| BEFORE  | INPUT | AFTER    | NOTE                                                                 |
| ------- | ----- | -------- | -------------------------------------------------------------------- |
| `│foo`  | `(`   | `(│foo`  | followed by a letter → only the opening char is inserted, no closing |
| `│foo`  | `"`   | `"│foo`  | same as above                                                        |
| `│.bar` | `{`   | `{│.bar` | followed by `.` → suppressed                                         |

## 3. Apostrophe in contractions/words — `'` right after a word

| Before | Input | After | Note |
|---|---|---|---|
| `I│` | `'` | `I'│` | lexima default: `'` after a letter is not paired (`I'm` / `don't`) |
| `don│` | `'` | `don'│` | same as above |

## 4. Skip over the closing char (leave-over) — cursor already before the closing char

| BEFORE | INPUT | AFTER | NOTE                             |
| ------ | ----- | ----- | -------------------------------- |
| `(│)`  | `)`   | `()│` | nothing inserted, just skip over |
| `"│"`  | `"`   | `""│` | skip over                        |
| `'│'`  | `'`   | `''│` | skip over                        |
| `<│>`  | `>`   | `<>│` | skip over                        |

## 5. `<<` (second `<`)

| BEFORE | INPUT | AFTER | NOTE                                                   |
| ------ | ----- | ----- | ------------------------------------------------------ |
| `<│>`  | `<`   | `<<│` | second `<` → becomes `<<`, no longer treated as a pair |

## 6. After the escape char `\`

| BEFORE   | INPUT   | AFTER       | NOTE                                               |
| -------- | ------- | ----------- | -------------------------------------------------- |
| `\│`     | `"`     | `\"│\"`     | `\`+quote → escaped quote, paired                  |
| `\│`     | `'`     | `\'│\'`     | same as above                                      |
| `` \│ `` | `` ` `` | `` \`│\` `` | escaped backtick, paired                           |
| `\│`     | `[`     | `\[│`       | `\`+bracket → escaped, not paired (lexima default) |

## 7. Triple quotes (markdown / docstring)

| BEFORE    | INPUT   | AFTER         | NOTE                      |
| --------- | ------- | ------------- | ------------------------- |
| `""│`     | `"`     | `"""│"""`     | third quote → triple pair |
| `''│`     | `'`     | `'''│'''`     | same as above             |
| `` ``│ `` | `` ` `` | `` ```│``` `` | same as above             |

## 8. Backspace deletes the whole pair

| BEFORE | INPUT  | AFTER | NOTE                                                  |
| ------ | ------ | ----- | ----------------------------------------------------- |
| `(│)`  | `<BS>` | `│`   | delete the opening char → closing char is removed too |
| `"│"`  | `<BS>` | `│`   | same as above                                         |

---

> [!NOTE]
> Groups 1, 2, 3, 6, 8 are actual results measured with `feedkeys` in headless nvim;
> groups 4 (leave), 5 (`<<`), 7 (triple) are from lexima's standard behavior + screenshot confirmation.
