
## pip CLI reference — bash-completion data

> verified against pip 26.2.1 / docs en/latest<br>
> sources:
> - per-command pages under [https://pip.pypa.io/en/latest/cli/*](https://pip.pypa.io/en/latest/cli/)
> - plus pip source [src/pip/_internal/cli/cmdoptions.py](https://github.com/pypa/pip/blob/main/src/pip/_internal/cli/cmdoptions.py) and [commands/completion.py](https://github.com/pypa/pip/blob/main/src/pip/_internal/commands/completion.py) at tag 26.2.1

### 1. Subcommands (authoritative, from commands/__init__.py)
```bash
install  lock  download  uninstall  freeze  inspect  list  show  check
config  search  cache  index  wheel  hash  completion  debug  help
```

Nested subcommands:

| Command    | Sub-actions (verbatim)                        | Source page   |
| ---------- | --------------------------------------------- | ------------- |
| config     | list edit get set unset debug                 | pip_config    |
| cache      | dir info list remove purge                    | pip_cache     |
| index      | versions                                      | pip_index     |
| completion | shell flags: --bash --zsh --fish --powershell | completion.py |

### 2. Options with a FIXED SET OF CHOICES

| OPTION (LONG / SHORT) | APPLIES TO                                  | EXACT ALLOWED VALUES                                                                                   | DEFAULT        | SOURCE                      |
| --------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------ | -------------- | --------------------------- |
| `--progress-bar`      | global (install, download, wheel, lock, …)  | auto on off raw                                                                                        | auto           | pip_install                 |
| `--upgrade-strategy`  | install                                     | eager only-if-needed                                                                                   | only-if-needed | pip_install                 |
| `--root-user-action`  | install, uninstall                          | warn ignore                                                                                            | warn           | pip_install / pip_uninstall |
| `--keyring-provider`  | global                                      | auto disabled import subprocess                                                                        | auto           | pip (general)               |
| `--exists-action`     | global (install/download/wheel)             | first-letter tokens: s i w b a (i.e. (s)witch (i)gnore (w)ipe (b)ackup (a)bort)                        | prompt         | pip (general)               |
| `--use-feature`       | global                                      | fast-deps inprocess-build-deps venv-isolation truststore no-binary-enable-wheel-cache build-constraint | —              | cmdoptions.py 26.2.1        |
| `--use-deprecated`    | global                                      | legacy-resolver legacy-certs                                                                           | —              | cmdoptions.py 26.2.1        |
| `--implementation`    | download, index, debug                      | pp jy cp ip py                                                                                         | current interp | pip_download                |
| `--format`            | list                                        | columns freeze json                                                                                    | columns        | pip_list                    |
| `--format`            | cache                                       | human abspath                                                                                          | human          | pip_cache                   |
| `-a`, `--algorithm`   | hash                                        | sha256 sha384 sha512                                                                                   | sha256         | pip_hash                    |
| `--no-binary`         | install, download, wheel, list, index, lock | special tokens :all: :none: (or comma-separated package names)                                         | —              | pip_install                 |
| `--only-binary`       | install, download, wheel, list, index, lock | special tokens :all: :none: (or comma-separated package names)                                         | —              | pip_install                 |
| `--all-releases`      | install, download, wheel, list, index, lock | :all: :none: (or package names)                                                                        | —              | pip_install                 |
| `--only-final`        | install, download, wheel, list, index, lock | :all: :none: (or package names)                                                                        | —              | pip_install

> [!NOTE]
> - Scope-selector flags (mutually-exclusive value-less flags, useful as completions on config): `--global` `--user` `--site`.
> - Config subcommand toggles worth completing as a set: on config, `--editor <path>`, `--global`, `--user`, `--site`.
> - Options that take arbitrary values (do NOT put in a choices table): `--python` (interpreter path/version spec), `--python-version` (free version string e.g. 3, 3.12, 3.12.1), `--platform`, `--abi`, `-C`/`--config-settings (KEY=VALUE)`, `--group ([path:]name)`, `--proxy`, `--trusted-host`, `--uploaded-prior-to`, `--refresh-package`, `--exclude`.

### 3. Options taking FILE / DIRECTORY / PATH / URL arguments (offer filesystem/url completion)

| Option (long / short)        | Type            | Commands                                          | Notes                                       |
| ---------------------------- | --------------- | ------------------------------------------------- | ------------------------------------------- |
| `-r`, `--requirement`        | FILE            | install, download, wheel, lock, uninstall, freeze | requirements.txt or pylock.toml; repeatable |
| `-c`, `--constraint`         | FILE            | install, download, wheel, lock                    | repeatable                                  |
| `--build-constraint`         | FILE            | install, download, wheel, lock                    | repeatable                                  |
| `--requirements-from-script` | FILE            | install, download, wheel, lock                    | PEP 723 script                              |
| `-e`, `--editable`           | PATH or URL     | install, wheel, lock                              | local project path or VCS url               |
| `-t`, `--target`             | DIRECTORY       | install                                           |                                             |
| `--prefix`                   | DIRECTORY       | install                                           |                                             |
| `--root`                     | DIRECTORY       | install                                           |                                             |
| `--src`                      | DIRECTORY       | install, download, wheel, lock                    | editable checkout dir                       |
| `-d`, `--dest`               | DIRECTORY       | download                                          |                                             |
| `-w`, `--wheel-dir`          | DIRECTORY       | wheel                                             |                                             |
| `-o`, `--output`             | FILE            | lock                                              | pylock.toml name; - = stdout                |
| `--report`                   | FILE            | install                                           | JSON; - = stdout                            |
| `-f`, `--find-links`         | URL or DIR/PATH | install, download, wheel, list, index, lock       | html file url or local dir                  |
| `-i`, `--index-url`          | URL             | install, download, wheel, list, index, lock       |                                             |
| `--extra-index-url`          | URL             | install, download, wheel, list, index, lock       | repeatable                                  |
| `--path`                     | PATH/DIRECTORY  | list, freeze, inspect                             | repeatable                                  |
| `--log`                      | FILE (PATH)     | global                                            | verbose log file                            |
| `--cache-dir`                | DIRECTORY       | global                                            |                                             |
| `--cert`                     | FILE (PATH)     | global                                            | PEM CA bundle                               |
| `--client-cert`              | FILE (PATH)     | global                                            | SSL client cert                             |
| `--editor`                   | FILE (PATH)     | config                                            | editor executable                           |
| `<file>` (positional)        | FILE            | hash                                              | archive file(s) to hash                     |
