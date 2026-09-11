; extends
; base git_config query has `(comment) @comment @spell`, so comment prose stays
; spell-checked. the forked grammar (marslo/tree-sitter-git-config) parses [k]ey-hotkey
; annotations (e.g. `# [p]retty [l]og`, `[a]lia[s]`, `pre[t]ty`, `[f]in[d]`) as their
; own `hotkey` nodes; exempt only those from spell. a whole-word bracket with no inner
; bracket (`[alias]`, `[find]`) is NOT a hotkey node, so it stays spellable.
(hotkey) @nospell
