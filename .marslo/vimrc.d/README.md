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

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


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

| SHORTCUT  | MODE | COMMENTS                              |
|-----------|------|---------------------------------------|
| `,cl`     | n    | `coc-codelens-action`                 |
| `,ac`     | n    | `coc-codeaction-cursor`               |
| `,as`     | n    | `coc-codeaction-source`               |
| `,a`      | n/x  | `coc-codeaction-selected`             |
| `,qf`     | n    | `coc-fix-current` (quickfix)          |
|           |      |                                       |
| `[g`      | n    | `coc-diagnostic-prev`                 |
| `]g`      | n    | `coc-diagnostic-next`                 |
| `gd`      | n    | `coc-definition`                      |
| `gy`      | n    | `coc-type-definition`                 |
| `gi`      | n    | `coc-implementation`                  |
| `gr`      | n    | `coc-references`                      |
| `K`       | n    | show documentation (hover)            |
|           |      |                                       |
| `<C-S-j>` | i    | `coc-snippets-expand`                 |
| `<C-j>`   | v    | `coc-snippets-select`                 |
| `<C-j>`   | i    | snippet expand or jump                |
| `<C-k>`   | -    | snippet prev (via `coc_snippet_prev`) |
| `<DOWN>`  | i    | coc popup next item                   |
| `<UP>`    | i    | coc popup prev item                   |
| `<C-M>`   | i    | coc popup confirm                     |
|           |      |                                       |
| `:OR`     | cmd  | organize imports                      |

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
| `;`                   | n/x/o | repeat last textobject move forward           |
| `,`                   | n/x/o | repeat last textobject move backward          |
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

| COMMAND             | ARGS               | SOURCE                                                                              | COMMENTS                                           |
|---------------------|--------------------|-------------------------------------------------------------------------------------|----------------------------------------------------|
| `:Reverse`          | `[range]`          | [cmds](cmds)                                                                        | reverse lines in range (default: whole file)       |
| `:Silent <cmd>`     | `<cmd>`            | [cmds](cmds)                                                                        | execute shell command silently and redraw          |
| `:DocTocUpdate [n]` | `[maxlevel]`       | [cmds](cmds)                                                                        | update existing doctoc (default maxlevel=3)        |
| `:DocTocCreate [n]` | `[maxlevel]`       | [cmds](cmds)                                                                        | create new doctoc (default maxlevel=3)             |
| `:First <char>`     | `<char>` `[range]` | [cmds](cmds)                                                                        | tabularize by first occurrence of char             |
| `:Iname`            | -                  | [cmds](cmds)                                                                        | echo absolute path of current file                 |
| `:FormatJSON`       | `[range]`          | [cmds](cmds)                                                                        | format JSON via `jq`                               |
| `:Hitest`           | -                  | [cmds](cmds)                                                                        | echo syntax highlight stack at cursor              |
| `:FixSyntax`        | -                  | [cmds](cmds)                                                                        | `syntax sync fromstart` to fix broken highlighting |
| `:TabMessage <cmd>` | `<cmd>`            | [functions](functions)                                                              | redirect ex-command output into a new tab          |
| `:GetPlug`          | -                  | [functions](functions)                                                              | download vim-plug to `~/.vim/autoload/plug.vim`    |
| `:GetVim`           | -                  | [functions](functions)                                                              | `marslofunc#GetVim()` (requires MarsloFunc plugin) |
| `:PlugUpdateHTTPS`  | -                  | [functions](functions)                                                              | PlugUpdate over HTTPS (bypass GnuPG SSH agent)     |
| `:OR`               | -                  | [extension](extension)                                                              | coc - organize imports                             |
| `:Files [dir]`      | `[dir]`            | [extension](extension)                                                              | fzf files with bat preview (overrides fzf.vim)     |
| `:LS [dir]`         | `[dir]`            | [extension](extension)                                                              | fzf `ls` output in given directory                 |
| `:TSInstallAll`     | -                  | [lua/config/nvim-treesitter.lua](../../.config/nvim/lua/config/nvim-treesitter.lua) | install all configured treesitter parsers          |
| `:DebugCursor`      | -                  | [plugin/dynamic-cursor.lua](../../.config/nvim/plugin/dynamic-cursor.lua)           | print extmarks + treesitter captures at cursor     |

---

## Command Abbreviations

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
