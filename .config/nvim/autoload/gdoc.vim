" gdoc: show javadoc for classpath symbols, backed by the offline index built
" by ~/.marslo/bin/lsp-gdoc (extracted *-sources.jar + ctags with line: field,
" plus a javadoc-map.tsv for *-javadoc.jar html fallback).
"
" :call gdoc#hover()   show doc for the symbol under the cursor
" :call gdoc#build()   (re)build the index asynchronously

let s:home     = expand('~/.cache/nvim/gdoc')
let s:tagsfile = s:home . '/.tags'
let s:jdmap    = s:home . '/javadoc-map.tsv'
let s:builder  = expand('~/.marslo/bin/lsp-gdoc')
let s:tags     = []
let s:mtime    = -1
let s:win      = -1

" ---- javadoc extraction (same rules as coc/source/groovy_tags.vim) ----------
function! s:clean_doc(lines) abort
  let out = []
  for l in a:lines
    let t = substitute(l,  '^\s*/\?\*\+/\?\s\?', '', '')
    let t = substitute(t,  '\*\+/\s*$', '', '')
    let t = substitute(t,  '{@code\s\+\([^}]*\)}', '`\1`', 'g')
    let t = substitute(t,  '{@link\s\+#\?\([^}]*\)}', '\1', 'g')
    let t = substitute(t,  '{@\w\+\s\+\([^}]*\)}', '\1', 'g')
    let t = substitute(t,  '<[^>]\+>', '', 'g')
    let t = substitute(t,  '&lt;', '<', 'g')
    let t = substitute(t,  '&gt;', '>', 'g')
    let t = substitute(t,  '&amp;', '\&', 'g')
    let t = substitute(t,  '&nbsp;', ' ', 'g')
    let t = substitute(t,  '\s\+$', '', '')
    call add(out, t)
  endfor
  while len(out) && out[0]  =~# '^\s*$' | call remove(out, 0)  | endwhile
  while len(out) && out[-1] =~# '^\s*$' | call remove(out, -1) | endwhile
  return out
endfunction

function! s:doc_above(lines, defidx) abort
  let i = a:defidx - 1
  while i >= 0 && a:lines[i] =~# '^\s*$'
    let i -= 1
  endwhile
  if i < 0 || a:lines[i] !~# '\*/\s*$'
    return []
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

" ---- index lookup -----------------------------------------------------------
function! s:load() abort
  if !filereadable(s:tagsfile) | return | endif
  let mt = getftime(s:tagsfile)
  if mt != s:mtime
    let s:tags  = filter(readfile(s:tagsfile), 'v:val[0] !=# "!"')
    let s:mtime = mt
  endif
endfunction

" pick the best tag line for name (prefer a class-qualified match)
function! s:find(name, class) abort
  call s:load()
  let pre  = a:name . "\t"
  let hits = filter(copy(s:tags), 'stridx(v:val, pre) == 0')
  if empty(hits) | return '' | endif
  if !empty(a:class)
    let want = '\tclass:' . escape(a:class, '\') . '\%(\t\|$\)'
    let byc  = filter(copy(hits), 'v:val =~# want')
    if !empty(byc) | return byc[0] | endif
  endif
  return hits[0]
endfunction

function! s:entry_doc(entry) abort
  let f    = split(a:entry, "\t")
  if len(f) < 2 | return [] | endif
  let file = f[1]
  let ln   = 0
  for x in f[3:]
    if x =~# '^line:' | let ln = str2nr(x[5:]) | endif
  endfor
  if ln <= 0 || !filereadable(file) | return [] | endif
  return s:doc_above(readfile(file), ln - 1)
endfunction

" class-level fallback: render Class.html from a *-javadoc.jar via pandoc
function! s:html_doc(cls) abort
  if !filereadable(s:jdmap) | return [] | endif
  for l in readfile(s:jdmap)
    let f = split(l, "\t")
    if len(f) < 3 | continue | endif
    if f[0] ==# a:cls || f[0] =~# '\.' . escape(a:cls, '\') . '$'
      let cmd = 'unzip -p ' . shellescape(f[1]) . ' ' . shellescape(f[2]) . ' | pandoc -f html -t plain 2>/dev/null'
      let out = systemlist(cmd)
      call filter(out, 'v:val !~# "^\\s*$" || 1')
      return out[0 : min([len(out) - 1, 80])]
    endif
  endfor
  return []
endfunction

" ---- float window -----------------------------------------------------------
function! s:close() abort
  if s:win > 0 && nvim_win_is_valid(s:win)
    call nvim_win_close(s:win, v:true)
  endif
  let s:win = -1
endfunction

function! s:float(lines) abort
  if !has('nvim') || empty(a:lines)
    echo join(a:lines, "\n")
    return
  endif
  let w = 20
  for l in a:lines | let w = max([w, strdisplaywidth(l)]) | endfor
  let w = min([w, 100])
  let h = min([max([len(a:lines), 1]), 24])
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, a:lines)
  call setbufvar(buf, '&filetype', 'markdown')
  call setbufvar(buf, '&modifiable', 0)
  call s:close()
  let s:win = nvim_open_win(buf, v:false, {
    \ 'relative': 'cursor', 'row': 1, 'col': 0,
    \ 'width': w, 'height': h, 'style': 'minimal', 'border': 'rounded' })
  augroup gdoc_float
    autocmd!
    autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave * ++once call s:close()
  augroup END
endfunction

" ---- public -----------------------------------------------------------------
function! gdoc#hover() abort
  let word = expand('<cword>')
  if empty(word) | echo 'gdoc: no symbol' | return | endif
  " qualifier immediately before the word, e.g. `URLEncoder.encode` -> URLEncoder
  let before = getline('.')[0 : col('.') - 1]
  let cls    = matchstr(before, '\<\zs[A-Za-z_][A-Za-z0-9_]*\ze\s*\.\s*\w*$')

  let doc = s:entry_doc(s:find(word, cls))
  if empty(doc) && word =~# '^[A-Z]'
    let doc = s:html_doc(word)
  endif
  if empty(doc)
    echo 'gdoc: no doc for ' . word
    return
  endif
  call s:float(doc)
endfunction

function! gdoc#build(...) abort
  let args = join(a:000, ' ')
  echo 'gdoc: building index ...'
  call jobstart(['bash', s:builder, '--build'] + a:000, {
    \ 'on_exit': {-> execute('let s:mtime = -1 | echo "gdoc: index rebuilt"')} })
endfunction

" vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=vim:
