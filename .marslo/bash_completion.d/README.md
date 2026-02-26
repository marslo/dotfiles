
# in .bashrc
```bash
type -P kubectl >/dev/null && eval "$(command kubectl completion bash)"
type -P npm     >/dev/null && eval "$(npm completion)"                  # ~/.npm/lib/node_modules/npm-completion/npm-completion.sh
type -P gh      >/dev/null && eval "$(gh copilot alias -- bash)"
type -P bat     >/dev/null && eval "$(bat --completion bash)"
type -P pipx    >/dev/null && eval "$(register-python-argcomplete pipx)"
type -P pip     >/dev/null && eval "$(pip completion --bash)"
type -P poetry  >/dev/null && eval "$(poetry completions bash)"
```

# create completion file
```bash
$ command kubectl completion bash          > kubectl.sh
$ command npm completion                   > npm.sh
$ command gh copilot alias -- bash         > gh.copilot.sh
$ command gh completion -s bash            > gh.bash.sh
$ command bat --completion bash            > bat.sh
$ command register-python-argcomplete pipx > pipx.sh
$ command pip completion --bash            > pip.sh
$ command poetry completions bash          > poetry.sh
```

## for code

> @credit: https://github.com/microsoft/vscode/blob/main/resources/completions/bash/code

```bash
$ curl -fsSL https://github.com/microsoft/vscode/raw/main/resources/completions/bash/code |
  sed 's/@@APPNAME@@/code/g' > code.sh
```
