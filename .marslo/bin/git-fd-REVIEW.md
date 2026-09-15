# git-fd Review & Implementation Plan

## 1. --branch 功能（已实现）

### 参数语义
- `-b, --branch <spec>`: 指定搜索范围，默认当前分支 (HEAD)

### 支持的 spec 类型

| spec 值 | 行为 | git 命令 |
|---------|------|----------|
| `all` 或 `*` | 全分支搜索 | `git log --all` |
| 具体分支名 | 单分支（精确匹配） | `git log <branch>` |
| glob 模式 | 如 `sandbox/marslo/*` | `git log --branches='<pattern>'` |

### 实现细节
- 精确分支名（如 `main`）使用 `logCmd+=("${BRANCH}")`，避免 `--branches=main` 误匹配 `main/*`
- glob 通过 `[[ "${BRANCH}" =~ [\?\*\[] ]]` 检测，使用 `--branches="${BRANCH}"`
- `getBranchRefs()` 解析 refs：all/* → refs/heads + refs/remotes；否则 → refs/heads/${BRANCH} + refs/remotes/origin/${BRANCH}

---

## 2. 与现有需求的对照

| 需求 | 状态 | 说明 |
|------|------|------|
| `-u, --author` 默认为当前用户 | ✅ 已实现 | `git config user.email` |
| `-b, --branch` | ✅ 已实现 | all/*、精确名、glob |
| `-e, --ext` | ✅ 已有 | 含 rename/move |
| `-f, --file` 模糊/glob 查询 | ✅ 已有 | glob 用 `[[ == ]]`，否则 grep -i |
| `-g, --grep` | ✅ 已有 | 支持 branch refs |
| `-k, --keyword` | ✅ 已有 | diff 搜索 (-G)，含 pathSpecs 支持 deleted/renamed |
| `-m, --message` | ✅ 已有 | --grep + --regexp-ignore-case |
| `--delete/add/modify/rename` 等 | ✅ 已有 | 保持不变 |

---

## 3. --fzf 模式（已实现）

### 输出与解析
- `getOutput()` 输出 null 分隔块：`commit path1\npath2\n\0`
- 使用 `mapfile -d '' files < <(fzf ...)` 避免 `$()` 的 null 字节警告
- fzf 参数：`--read0 --print0`

### fzf 配置
| 项 | 值 |
|----|-----|
| height | 60% |
| preview | `git show -s --color=never {1} \| bat --language 'git show' --plain --theme 'Catppuccin Mocha' --color=always` |
| prompt/info | 自定义（nerd font 图标） |

### 按键绑定
| 键 | 行为 |
|----|------|
| ENTER | 接受选择，仅显示 log（不打开 vim） |
| CTRL-/ | diff 用 bat 全屏显示 |
| CTRL-F | 完整 diff 用 less 显示 |

### gdetail（CTRL-F）
- `git show -s` 经 bat 高亮（Catppuccin Mocha）
- CHANGED FILES 列表
- `git diff --color=always` 原始 diff

### gdiffbat（CTRL-/）
- `git show {1} --format= --patch \| bat --plain --theme gruvbox-material-dark --language diff --paging=always`

### Enter 后处理
- 仅调用 `showSingleCommit` 显示 log
- 不打开 vim（Ctrl+O 因 TTY 问题已移除）

---

## 4. 文件搜索相关选项（保持不变）

- `--delete`, `--no-delete`
- `--add`, `--no-add`
- `--modify`, `--no-modify`
- `--rename`, `--no-rename`
- `--blob <hash>`

---

## 5. 依赖与配置

- **bat**：preview 与 gdetail 使用，需 `Git Show` 语法（见 `~/.config/bat/syntaxes/GitShow.sublime-syntax`）
- **fzf**：交互选择
- `bat cache --build`：修改语法文件后需执行
