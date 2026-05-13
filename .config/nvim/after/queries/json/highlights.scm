; Replacement for nvim-treesitter json/highlights.scm
; Removes conceal on double quotes so they stay visible

[
  (true)
  (false)
] @boolean

(null) @constant.builtin

(number) @number

(pair
  key: (string) @property)

(pair
  value: (string) @string)

(array
  (string) @string)

[
  ","
  ":"
] @punctuation.delimiter

[
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

("\"") @punctuation.delimiter

(escape_sequence) @string.escape

(comment) @comment @spell
