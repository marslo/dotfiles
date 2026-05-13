; Block-level compound statements
[
  (function_definition)
  (if_statement)
  (for_loop)
] @indent.begin

; Augroup blocks (vim parser treats opening/closing as flat siblings)
(augroup_statement
  (augroup_name) @_name
  (#not-eq? @_name "END")) @indent.begin

(augroup_statement
  (augroup_name) @_name
  (#eq? @_name "END")) @indent.branch @indent.end

; Branch nodes: align with the opening keyword of the enclosing block
[
  "endfunction"
  "endif"
  "endfor"
  "endwhile"
  "endtry"
  "else"
  "elseif"
  "catch"
  "finally"
  (else_statement)
  (elseif_statement)
] @indent.branch

; End markers
[
  "endfunction"
  "endif"
  "endfor"
  "endwhile"
  "endtry"
] @indent.end

(comment) @indent.auto
