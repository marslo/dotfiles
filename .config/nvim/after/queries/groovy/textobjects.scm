; functions (def foo() { ... })
(function_definition) @function.outer

(function_definition
  body: (closure
    .
    "{"
    _+ @function.inner
    "}"))

; abstract / interface method declarations (no body)
(function_declaration) @function.outer

; classes
(class_definition
  body: (closure) @class.inner) @class.outer

; parameters – definition site
(parameter_list
  "," @parameter.outer
  .
  (parameter) @parameter.inner @parameter.outer)

(parameter_list
  .
  (parameter) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; parameters – call site
(argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; comments
[
  (comment)
  (groovy_doc)
] @comment.outer

; loops
(for_loop
  body: (_)? @loop.inner) @loop.outer

(for_in_loop
  body: (_)? @loop.inner) @loop.outer

(while_loop
  body: (_)? @loop.inner) @loop.outer

(do_while_loop
  body: (_)? @loop.inner) @loop.outer

; conditionals
(if_statement
  body: (_)? @conditional.inner) @conditional.outer

; blocks
(closure) @block.outer
