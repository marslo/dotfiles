# Custom Bash Completion Overrides

This directory is dedicated to specific Bash completion scripts designed to override system-wide defaults using high-priority loading mechanisms.

## 1. Purpose and Rationale

### Priority and Overriding Mechanism

**scripts located in the user-defined completion directory take precedence over system-wide scripts.**
The `bash-completion` framework searches for scripts in a specific order:

- **User Directory** (`BASH_COMPLETION_USER_DIR`) -> **System Directory**

Once it finds a match (e.g., `scp`) in your custom path, it stops searching, effectively ensuring your optimized version is used.

### What's Different in the `scp` Script?

the `scp` script is modified from the original one in `/opt/homebrew/share/bash-completion/completions/scp` with the following changes:
- **Case Insensitive Matching**
  - enable `shopt -s nocaseglob` in the function `_comp_xfunc_scp_compgen_remote_files()` for remote system
  - enable `-o default` option in the `compgen` command to allow case-insensitive matching for local system

### Why not just modify the system-wide script?

Modifying system-wide scripts is generally discouraged for several reasons:
- **Maintenance and Updates**: System-wide scripts may be updated by package managers, which can overwrite your changes
- **Portability**: Custom scripts in a user directory can be easily transferred across systems without needing root access

## 2. Configuration for Priority Loading

To ensure Bash prioritizes this directory during the lookup process, you must configure the `BASH_COMPLETION_USER_DIR` environment variable in your `~/.bashrc` or `~/.bash_profile`.

### Setup
Add the following lines to your Shell configuration file:

```bash
# setup user-level bash completion directory
export BASH_COMPLETION_USER_DIR="${HOME}/.marslo/bash_completion.d"

# check via $ brew info bash-completion@2
if [ -f "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi
```

## Info for Completion

There're 2 folders for system-level completion scripts ( in macOS ):

- `/opt/homebrew/share/bash-completion` | `/opt/homebrew/share/bash-completion/completions`
- `/opt/homebrew/etc/bash_completion.d`

| PATH                                  | MECHANISMS        | DESCRIPTION                                                                        |
|---------------------------------------|-------------------|------------------------------------------------------------------------------------|
| `/opt/homebrew/share/bash-completion` | **Lazy Loading**  | for bash-completion v2.x; scripts must be placed in the `completions` subdirectory |
| `/opt/homebrew/etc/bash_completion.d` | **Eager Loading** | for bash-completion v1.x; scripts are sourced immediately on shell startup         |


### Tips for Lazy Loading

- **Naming Conventions**: Ensure your script is named exactly after the command it completes (e.g., `scp` for `scp` command) to be recognized by the lazy loading mechanism
- **Location**: Place the optimized scripts in the `completions` subdirectory to ensure they are loaded correctly by the `bash-completion` framework

---

maintained by @marslo
