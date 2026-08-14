function! coc#source#groovy_tags#init() abort
  return {
    \ 'priority': 99,
    \ 'shortcut': 'GT',
    \ 'filetypes': ['groovy', 'Jenkinsfile', 'jenkinsfile'],
    \ 'triggerCharacters': ['.'],
    \ 'triggerOnly': v:true
    \ }
endfunction

" locate the def/constant line of `name` in source lines, mirroring ~/.ctags.d/groovy.ctags
function! s:find_def(lines, name, kind) abort
  let n = escape(a:name, '\')
  let re = a:kind ==# 'C'
    \ ? '\C^\s*\%(@Field\s\+\)\?\%(static\s\+\)\?final\>.*\<' . n . '\>\s*='
    \ : '\C^\s*\%(\%(private\|public\|protected\|abstract\|final\|static\)\s\+\)*\%(def\|void\|byte\|int\|short\|long\|float\|double\|boolean\|char\|[A-Z][A-Za-z0-9_]*\%(<[^(]*>\)\?\)\s\+' . n . '\s*('
  for idx in range(len(a:lines))
    if a:lines[idx] =~# re | return idx | endif
  endfor
  return -1
endfunction

" strip javadoc markers / tags / html so the block reads as plain text
function! s:clean_doc(lines) abort
  let out = []
  for l in a:lines
    let t = substitute(l,  '^\s*/\?\*\+/\?\s\?', '', '')    " leading /** , * , **/ , */ + one space
    let t = substitute(t,  '\*\+/\s*$', '', '')             " trailing **/ or */
    let t = substitute(t,  '{@code\s\+\([^}]*\)}', '`\1`', 'g')
    let t = substitute(t,  '{@link\s\+#\?\([^}]*\)}', '\1', 'g')
    let t = substitute(t,  '{@\w\+\s\+\([^}]*\)}', '\1', 'g')
    let t = substitute(t,  '<[^>]\+>', '', 'g')             " html tags
    let t = substitute(t,  '&lt;', '<', 'g')
    let t = substitute(t,  '&gt;', '>', 'g')
    let t = substitute(t,  '&amp;', '\&', 'g')
    let t = substitute(t,  '&nbsp;', ' ', 'g')
    let t = substitute(t,  '\s\+$', '', '')
    call add(out, t)
  endfor
  while len(out) && out[0]  =~# '^\s*$' | call remove(out, 0)  | endwhile
  while len(out) && out[-1] =~# '^\s*$' | call remove(out, -1) | endwhile
  return join(out, "\n")
endfunction

" collect the /** ... **/ block immediately above the def line (0-based)
function! s:doc_above(lines, defidx) abort
  let i = a:defidx - 1
  while i >= 0 && a:lines[i] =~# '^\s*$'
    let i -= 1
  endwhile
  if i < 0 || a:lines[i] !~# '\*/\s*$'
    return ''
  endif
  let doc = []
  while i >= 0
    call add(doc, a:lines[i])
    if a:lines[i] =~# '^\s*/\*'
      break
    endif
    let i -= 1
  endwhile
  call reverse(doc)
  return s:clean_doc(doc)
endfunction

function! s:doc_for(lines, name, kind) abort
  let defidx = s:find_def(a:lines, a:name, a:kind)
  return defidx < 0 ? '' : s:doc_above(a:lines, defidx)
endfunction

function! coc#source#groovy_tags#complete(opt, cb) abort
  let line = a:opt['line']
  let col = a:opt['col']
  let prefix = line[0:col-1]
  let word = matchstr(prefix, '\w\+\.$')
  let word = substitute(word, '\.$', '', '')

  if empty(word)
    call a:cb([])
    return
  endif

  let pattern  = "\t" . 'vars/' . word . '.groovy' . "\t"
  let items    = []
  let seen     = {}
  let srccache = {}

  for tf in tagfiles()
    let fpath = fnamemodify(tf, ':p')
    if !filereadable(fpath) | continue | endif
    for entry in readfile(fpath)
      if entry[0] ==# '!' | continue | endif
      if stridx(entry, pattern) < 0 | continue | endif
      let fields = split(entry, '\t')
      if len(fields) < 4 | continue | endif
      let name = fields[0]
      let file = fields[1]
      let kind = matchstr(fields[-1], '^\w')
      if kind !~# '[bmufnoC]' | continue | endif
      if has_key(seen, name) | continue | endif
      let seen[name] = 1

      " read the source file (once per file) and extract the javadoc above the def
      let src = fnamemodify(fpath, ':h') . '/' . file
      if !has_key(srccache, src)
        let srccache[src] = filereadable(src) ? readfile(src) : []
      endif
      let doc = s:doc_for(srccache[src], name, kind)

      let label = kind ==# 'C' ? '[C] ' . file : '[F] ' . file
      let item  = { 'word': name, 'menu': label, 'sortText': tolower(name), 'dup': 0 }
      if !empty(doc) | let item.info = doc | endif
      call add(items, item)
    endfor
  endfor

  call a:cb(items)
endfunction
