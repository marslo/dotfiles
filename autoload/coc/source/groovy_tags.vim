function! coc#source#groovy_tags#init() abort
  return {
    \ 'priority': 99,
    \ 'shortcut': 'GT',
    \ 'filetypes': ['groovy', 'Jenkinsfile', 'jenkinsfile'],
    \ 'triggerCharacters': ['.'],
    \ 'triggerOnly': v:true
    \ }
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

  let pattern = "\t" . 'vars/' . word . '.groovy' . "\t"
  let items = []
  let seen = {}

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
      if kind !~# '[bmuf]' | continue | endif
      if has_key(seen, name) | continue | endif
      let seen[name] = 1
      call add(items, { 'word': name, 'menu': file, 'dup': 0 })
    endfor
  endfor

  call a:cb(items)
endfunction
