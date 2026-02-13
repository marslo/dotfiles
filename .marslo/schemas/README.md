## update.sh

to automatic downloading and patching [SchemaStore.org](https://schemastore.org) JSON schemas for offline use in Neovim + coc.nvim or other YAML-aware editors.

to fix the issue in yamllint warning:

> Problems loading reference 'https://json.schemastore.org/pre-commit-hooks. json#/definitions/stages': Unable to load schema from 'https://json. schemastore.org/pre-commit-hooks.json': <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN""http://www.w3.org/TR/html4/strict.dtd"> <HTML><HEAD><TITLE>Service Unavailable</TITLE> <META HTTP-EQUIV="Content-Type" Content="text/html; charset=us-ascii"></HEAD> <BODY><h2>Service Unavailable</h2> <hr><p>HTTP Error 503. The service is unavailable.</p> </BODY></HTML> . (YAML 768)

### features

- downloads selected schema files into a local `schemas/` directory
- replaces remote `$ref` URLs in `pre-commit-config.json` with local `file://` paths
- prints a valid `yaml.schemas` block for use in `coc-settings.json`
- fully offline schema validation

### supported schemas

- `.pre-commit-config.yaml`
- `.github/workflows/*.yml`
- `.yamllint.yaml`

### usage

```bash
$ bash update.sh
>> pre-commit-config.json downloaded
>> github-workflow.json downloaded
>> yamllint.json downloaded
>> pre-commit-hooks.json downloaded
>> use the following in coc-settings.json:
"yaml.schemas": {
  "file:///Users/marslo/.marslo/schemas/pre-commit-config.json": ".pre-commit-config.json",
  "file:///Users/marslo/.marslo/schemas/github-workflow.json": ".github-workflow.json",
  "file:///Users/marslo/.marslo/schemas/yamllint.json": ".yamllint.json"
}
```
