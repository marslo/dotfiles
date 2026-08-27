" groovy_tags: hover + go-to-definition for jenkins shared-library calls, where
" groovyls cannot resolve the dynamically-injected `color` / `constant` /
" `wrapper` ... globals, and mis-renders overloads/varargs.
"
" resolves the symbol under the cursor to its groovy source and shows/jumps to
" the def, echoing the SOURCE line verbatim (so `String... files` stays exact):
"   * `lib.member`        -> member of vars/<lib>.groovy      (cross-lib)
"   * bare `name( ... )`  -> def in the current buffer, else vars/<name>.groovy call()
" overloaded methods are disambiguated by the call's argument count.
"
" :call groovy_tags#hover()        show doc for the call under the cursor
" :call groovy_tags#definition()   jump to the def of the call under the cursor
" :call groovy_tags#setup()        buffer-local K / gd + idle auto-hover wiring
"
" g:groovy_tags_auto_hover  toggles the idle auto-hover (default on).
"   accepts 1/0, v:true/v:false, or 'yes'|'no'|'true'|'false'|'on'|'off'.
"   manual K (shift+k) is unaffected. changing it takes effect immediately (no reload).
" g:groovy_tags_auto_hover_delay  idle delay in ms before the popup. when set
"   (>= 0) a private CursorMoved debounce timer is used; when unset (or -1) it
"   falls back to CursorHold, i.e. &updatetime. also live, no reload.
"
" both fall back to the normal coc/tag behavior when the token under the cursor
" is not a resolvable groovy-lib call.

let s:win   = -1
let s:timer = -1

" truthy check accepting 1/0, v:true/v:false, and yes|no|true|false|on|off
function! s:enabled(val) abort
  let t = type(a:val)
  if t == v:t_bool   | return a:val == v:true | endif
  if t == v:t_number | return a:val != 0 | endif
  if t == v:t_string | return a:val =~? '^\%(1\|y\|yes\|true\|on\)$' | endif
  return 1
endfunction

" flip g:groovy_tags_auto_hover between on/off (echoes the new state)
function! groovy_tags#toggle_auto_hover() abort
  let g:groovy_tags_auto_hover = s:enabled(get(g:, 'groovy_tags_auto_hover', 1)) ? 0 : 1
  echo 'groovy_tags auto-hover: ' . (g:groovy_tags_auto_hover ? 'on' : 'off')
  return g:groovy_tags_auto_hover
endfunction

" ---- javadoc extraction (same rules as coc/source/groovy_tags.vim) ----------
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
  return out
endfunction

" collect the /** ... **/ block immediately above the def line (0-based)
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

" ---- def locators (mirror ~/.ctags.d/groovy.ctags) --------------------------
" 0-based index of the `@Field final ... NAME =` constant line, or -1
function! s:find_const(lines, name) abort
  let re = '\C^\s*\%(@Field\s\+\)\?\%(static\s\+\)\?final\>.*\<' . escape(a:name, '\') . '\>\s*='
  for idx in range(len(a:lines))
    if a:lines[idx] =~# re | return idx | endif
  endfor
  return -1
endfunction

" 0-based indices of every method def line named `name` (all overloads)
function! s:find_defs(lines, name) abort
  let re  = '\C^\s*\%(\%(private\|public\|protected\|abstract\|final\|static\)\s\+\)*\%(def\|void\|byte\|int\|short\|long\|float\|double\|boolean\|char\|[A-Z][A-Za-z0-9_]*\%(<[^(]*>\)\?\)\s\+' . escape(a:name, '\') . '\s*('
  let out = []
  for idx in range(len(a:lines))
    if a:lines[idx] =~# re | call add(out, idx) | endif
  endfor
  return out
endfunction

" ---- balanced-paren helpers -------------------------------------------------
" text inside the paren group opening at byte `open` in `line`, or v:null when
" the group does not close on this line. skips string literals.
function! s:paren_inner(line, open) abort
  if a:open < 0 || a:open >= len(a:line) || a:line[a:open] !=# '(' | return v:null | endif
  let depth = 0
  let i     = a:open
  let n     = len(a:line)
  let q     = ''
  let start = a:open + 1
  while i < n
    let c = a:line[i]
    if !empty(q)
      if c ==# '\' | let i += 2 | continue | endif
      if c ==# q   | let q = '' | endif
      let i += 1 | continue
    endif
    if c ==# "'" || c ==# '"' | let q = c | let i += 1 | continue | endif
    if c =~# '[([{]' | let depth += 1 | endif
    if c =~# '[)\]}]'
      let depth -= 1
      if depth == 0 | return a:line[start : i - 1] | endif
    endif
    let i += 1
  endwhile
  return v:null
endfunction

" split on top-level commas, honoring nested brackets and string literals
function! s:split_top(s) abort
  let out   = []
  let buf   = ''
  let depth = 0
  let q     = ''
  let i     = 0
  let n     = len(a:s)
  while i < n
    let c = a:s[i]
    if !empty(q)
      let buf .= c
      if c ==# '\' && i + 1 < n | let buf .= a:s[i + 1] | let i += 2 | continue | endif
      if c ==# q | let q = '' | endif
      let i += 1 | continue
    endif
    if c ==# "'" || c ==# '"' | let q = c | let buf .= c | let i += 1 | continue | endif
    if c =~# '[([{]' | let depth += 1 | endif
    if c =~# '[)\]}]' | let depth -= 1 | endif
    if c ==# ',' && depth == 0 | call add(out, buf) | let buf = '' | let i += 1 | continue | endif
    let buf .= c
    let i += 1
  endwhile
  call add(out, buf)
  return out
endfunction

" { count, vararg } for the param list of a def signature line
function! s:parse_params(line) abort
  let inner = s:paren_inner(a:line, stridx(a:line, '('))
  if inner is v:null      | return { 'count': -1, 'vararg': 0 } | endif
  if inner =~# '^\s*$'     | return { 'count':  0, 'vararg': 0 } | endif
  let parts = s:split_top(inner)
  return { 'count': len(parts), 'vararg': parts[-1] =~# '\.\.\.' }
endfunction

" byte col of the `(` that follows the word the cursor sits on, or -1
function! s:word_paren() abort
  let line = getline('.')
  let wend = col('.') - 1
  while wend < len(line) && line[wend] =~# '\w' | let wend += 1 | endwhile
  let p = wend
  while p < len(line) && line[p] =~# '\s' | let p += 1 | endwhile
  return (p < len(line) && line[p] ==# '(') ? p : -1
endfunction

" argument count of the call under the cursor, or -1 when not a single-line call
function! s:call_argc() abort
  let p = s:word_paren()
  if p < 0 | return -1 | endif
  let inner = s:paren_inner(getline('.'), p)
  if inner is v:null  | return -1 | endif
  if inner =~# '^\s*$' | return 0 | endif
  return len(s:split_top(inner))
endfunction

" ---- candidate collection ---------------------------------------------------
" one def -> a candidate dict
function! s:mk(path, lines, idx, kind) abort
  return {
    \ 'path'   : a:path,
    \ 'lnum'   : a:idx + 1,
    \ 'col'    : 1,
    \ 'kind'   : a:kind,
    \ 'sig'    : substitute(a:lines[a:idx], '^\s*\|\s*{\?\s*$', '', 'g'),
    \ 'doc'    : s:doc_above(a:lines, a:idx),
    \ 'params' : s:parse_params(a:lines[a:idx]),
    \ }
endfunction

" all defs (constant + method overloads) of `member` in `lines`
function! s:cands_from_lines(path, lines, member) abort
  let out = []
  let ci  = s:find_const(a:lines, a:member)
  if ci >= 0 | call add(out, s:mk(a:path, a:lines, ci, 'C')) | endif
  for idx in s:find_defs(a:lines, a:member)
    call add(out, s:mk(a:path, a:lines, idx, 'm'))
  endfor
  return out
endfunction

" candidates for `member` in vars/<lib>.groovy, via the tag index (gdoc-skipped)
function! s:collect_lib(lib, member) abort
  let pattern = "\t" . 'vars/' . a:lib . '.groovy' . "\t"
  let gdocdir = fnamemodify(expand('~/.cache/nvim/gdoc'), ':p')
  for tf in tagfiles()
    let fpath = fnamemodify(tf, ':p')
    if !filereadable(fpath) || stridx(fpath, gdocdir) == 0 | continue | endif
    for entry in readfile(fpath)
      if empty(entry) || entry[0] ==# '!' | continue | endif
      if stridx(entry, pattern) < 0 | continue | endif
      let fields = split(entry, '\t')
      if len(fields) < 4 || fields[0] !=# a:member | continue | endif
      let src = fnamemodify(fpath, ':h') . '/' . fields[1]
      if !filereadable(src) | continue | endif
      return s:cands_from_lines(src, readfile(src), a:member)
    endfor
  endfor
  return []
endfunction

" the `lib.member` pair spanning the cursor, e.g. `color.info` -> {lib,member}
function! groovy_tags#pair_under_cursor() abort
  let line  = getline('.')
  let cur   = col('.') - 1
  let start = 0
  while 1
    let m = matchstrpos(line, '\<\w\+\s*\.\s*\w\+\>', start)
    if m[1] < 0 | break | endif
    if cur >= m[1] && cur < m[2]
      let seg = m[0]
      return { 'lib': matchstr(seg, '^\w\+'), 'member': matchstr(seg, '\w\+$') }
    endif
    let start = m[2]
  endwhile
  return {}
endfunction

" resolve the symbol under the cursor to a list of candidate defs
function! s:candidates() abort
  let pair = groovy_tags#pair_under_cursor()
  if !empty(pair)
    return s:collect_lib(pair.lib, pair.member)
  endif
  " bare call: name( ... ) -> current buffer first, else vars/<name>.groovy call()
  if s:word_paren() < 0 | return [] | endif
  let member = expand('<cword>')
  if empty(member) | return [] | endif
  let cur = s:cands_from_lines(expand('%:p'), getline(1, '$'), member)
  return empty(cur) ? s:collect_lib(member, 'call') : cur
endfunction

" pick the overload matching `argc`, or {} when it cannot be decided
function! s:choose(cands, argc) abort
  if a:argc < 0 | return {} | endif
  for c in a:cands
    if !c.params.vararg && c.params.count == a:argc | return c | endif
  endfor
  for c in a:cands
    if c.params.vararg && a:argc >= c.params.count - 1 | return c | endif
  endfor
  return {}
endfunction

" ---- back-compat: first candidate for lib.member ----------------------------
function! groovy_tags#resolve(lib, member) abort
  let c = s:collect_lib(a:lib, a:member)
  return empty(c) ? {} : c[0]
endfunction

" ---- float window (mirrors autoload/gdoc.vim) -------------------------------
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
  augroup groovy_tags_float
    autocmd!
    autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave * ++once call s:close()
  augroup END
endfunction

" markdown lines for a set of candidate defs (all sigs, then the first doc)
function! s:render(cands) abort
  let out = ['```groovy']
  for c in a:cands | call add(out, c.sig) | endfor
  call add(out, '```')
  for c in a:cands
    if !empty(c.doc)
      call add(out, '')
      call extend(out, c.doc)
      break
    endif
  endfor
  return out
endfunction

" ---- public: hover ----------------------------------------------------------
" groovy_tags#hover()   manual (K): resolve the call, else fall back to coc
" groovy_tags#hover(1)  idle auto (CursorHold): resolve the call, else silent
function! groovy_tags#hover(...) abort
  let l:auto = a:0 > 0 && a:1
  if l:auto
    " g:groovy_tags_auto_hover toggles the idle popup (1/0, yes/no, true/false)
    if !s:enabled(get(g:, 'groovy_tags_auto_hover', 1)) | return | endif
    " scoped to groovy/Jenkinsfile so a global CursorHold stays cheap
    if index(['groovy', 'Jenkinsfile', 'jenkinsfile'], &filetype) < 0 | return | endif
  endif
  let cands = s:candidates()
  if empty(cands)
    if l:auto | return | endif
    return s:hover_fallback()
  endif
  let pick = len(cands) > 1 ? s:choose(cands, s:call_argc()) : cands[0]
  call s:float(s:render(empty(pick) ? cands : [pick]))
endfunction

" fall back to the normal coc hover (mirrors ShowDocumentation in vimrc.d/extension)
function! s:hover_fallback() abort
  if exists('*CocAction') && CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  elseif exists('*gdoc#hover')
    call gdoc#hover()
  else
    silent! call feedkeys('K', 'in')
  endif
endfunction

" ---- public: definition -----------------------------------------------------
function! groovy_tags#definition() abort
  let cands = s:candidates()
  if empty(cands)
    return s:definition_fallback()
  endif
  let pick = len(cands) > 1 ? s:choose(cands, s:call_argc()) : cands[0]
  if empty(pick) | let pick = cands[0] | endif
  normal! m'
  if fnamemodify(pick.path, ':p') !=# expand('%:p')
    execute 'edit ' . fnameescape(pick.path)
  endif
  call cursor(pick.lnum, pick.col)
  normal! zz
  if len(cands) > 1
    echo printf('groovy_tags: %d overloads -> arity %d', len(cands), pick.params.count)
  endif
endfunction

" fall back to coc definition, else a plain ctags jump (as in Jenkinsfile today)
function! s:definition_fallback() abort
  if exists('*CocAction') && CocAction('hasProvider', 'definition')
    call CocActionAsync('jumpDefinition')
    return
  endif
  try
    execute 'tjump ' . expand('<cword>')
  catch /E426\|E433\|E257/
    echohl WarningMsg | echo 'groovy_tags: no definition for ' . expand('<cword>') | echohl None
  endtry
endfunction

" ---- idle auto-hover scheduling ---------------------------------------------
" custom idle delay in ms, or -1 when unset (-> fall back to CursorHold)
function! s:delay() abort
  let d = get(g:, 'groovy_tags_auto_hover_delay', -1)
  if type(d) == v:t_string | let d = str2nr(d) | endif
  return type(d) == v:t_number ? d : -1
endfunction

function! s:cancel() abort
  if s:timer > 0 | call timer_stop(s:timer) | endif
  let s:timer = -1
endfunction

" CursorHold path: only the fallback, skip when a custom delay owns scheduling
function! s:on_hold() abort
  if s:delay() >= 0 | return | endif
  call groovy_tags#hover(1)
endfunction

" CursorMoved path: (re)arm the private debounce timer when a delay is set
function! s:debounce() abort
  if s:delay() < 0 | return | endif
  if !s:enabled(get(g:, 'groovy_tags_auto_hover', 1)) | return | endif
  call s:cancel()
  let s:timer = timer_start(s:delay(), function('s:tick'))
endfunction

function! s:tick(timer) abort
  let s:timer = -1
  if mode() ==# 'n' | call groovy_tags#hover(1) | endif
endfunction

" ---- public: per-buffer wiring ----------------------------------------------
" call from a FileType groovy,Jenkinsfile autocmd: buffer-local K / gd plus
" idle auto-hover. delay follows g:groovy_tags_auto_hover_delay, else &updatetime.
" idempotent across :e.
function! groovy_tags#setup() abort
  if get(b:, 'groovy_tags_setup', 0) | return | endif
  let b:groovy_tags_setup = 1
  nnoremap <silent><buffer> K  :call groovy_tags#hover()<CR>
  nnoremap <silent><buffer> gd :call groovy_tags#definition()<CR>
  augroup groovy_tags_buf
    autocmd! * <buffer>
    autocmd CursorHold           <buffer> call s:on_hold()
    autocmd CursorMoved          <buffer> call s:debounce()
    autocmd InsertEnter,BufLeave <buffer> call s:cancel()
  augroup END
endfunction

" vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=vim:
