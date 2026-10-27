
# in .bashrc
```bash
type -P kubectl >/dev/null && eval "$(command kubectl completion bash)"
type -P npm     >/dev/null && eval "$(command npm completion)"                  # ~/.npm/lib/node_modules/npm-completion/npm-completion.sh
type -P gh      >/dev/null && eval "$(command gh copilot alias -- bash)"
type -P bat     >/dev/null && eval "$(command bat --completion bash)"
type -P pipx    >/dev/null && eval "$(command register-python-argcomplete pipx)"
type -P pip     >/dev/null && eval "$(command pip completion --bash)"
type -P poetry  >/dev/null && eval "$(command poetry completions bash)"
type -p node    >/dev/null && eval "$(command node --completion-bash)"
```

# create completion file
```bash
$ command kubectl completion bash          > kubectl.bash
$ command npm completion                   > npm.bash     # sourced via npm-flags.bash
$ command gh copilot alias -- bash         > gh.copilot.sh
$ command gh completion -s bash            > gh.bash
$ command bat --completion bash            > bat.bash
$ command register-python-argcomplete pipx > pipx.bash
$ command pip completion --bash            > pip.bash     # deprecated
$ command poetry completions bash          > poetry.bash
```

## for code

> @credit: https://github.com/microsoft/vscode/blob/main/resources/completions/bash/code

```bash
$ curl -fsSL https://github.com/microsoft/vscode/raw/main/resources/completions/bash/code | sed 's/@@APPNAME@@/code/g' > code.sh
```
