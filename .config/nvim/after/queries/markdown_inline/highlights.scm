; Replacement for runtime markdown_inline/highlights.scm
; Only conceal inline links [text](url) — everything else stays visible

(code_span) @markup.raw @nospell
(emphasis) @markup.italic
(strong_emphasis) @markup.strong
(strikethrough) @markup.strikethrough

(shortcut_link (link_text) @nospell)

[(backslash_escape) (hard_line_break)] @string.escape

; Only conceal: [text](url)
(inline_link
  ["[" "]" "(" (link_destination) ")"] @markup.link
  (#set! conceal ""))

[(link_label) (link_text) (link_title) (image_description)] @markup.link.label

((inline_link (link_destination) @_url) @_label
  (#set! @_label url @_url))

((image (link_destination) @_url) @_label
  (#set! @_label url @_url))

[(link_destination) (uri_autolink) (email_autolink)] @markup.link.url @nospell

((uri_autolink) @_url
  (#offset! @_url 0 1 0 -1)
  (#set! @_url url @_url))

(entity_reference) @nospell

((entity_reference) @character.special (#eq? @character.special "&nbsp;") (#set! conceal " "))
((entity_reference) @character.special (#eq? @character.special "&lt;") (#set! conceal "<"))
((entity_reference) @character.special (#eq? @character.special "&gt;") (#set! conceal ">"))
((entity_reference) @character.special (#eq? @character.special "&amp;") (#set! conceal "&"))
((entity_reference) @character.special (#eq? @character.special "&quot;") (#set! conceal "\""))
((entity_reference) @character.special (#any-of? @character.special "&ensp;" "&emsp;") (#set! conceal " "))
