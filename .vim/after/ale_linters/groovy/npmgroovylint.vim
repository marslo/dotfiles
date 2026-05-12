" Author: lucas-str <lucas.sturelle@ik.me>
" Description: Integration of npm-groovy-lint for Groovy files.
" ---------------------------------
" Updated: marslo ( 2026.04.09 )
" Description: Override dense-analysis/ale: map npm-groovy-lint JSON `rule` -> ALE `code` so %code% / virtualtext show UnusedMethodParameter, etc.

" `ale#Set` writes a default value only if there is no corresponding key for `g:`, and will not overwrite the `g:ale_groovy_npmgroovylint_*` already set in `~/.marslo/vimrc.d/extension`.
call ale#Set('groovy_npmgroovylint_executable', 'npm-groovy-lint')
call ale#Set('groovy_npmgroovylint_options', '--loglevel warning')

function! ale_linters#groovy#npmgroovylint#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'groovy_npmgroovylint_options')

    return '%e --failon none --output json'
    \   . ale#Pad(l:options)
    \   . ' %t'
endfunction

function! ale_linters#groovy#npmgroovylint#Handle(buffer, lines) abort
    let l:output = []
    let l:json = ale#util#FuzzyJSONDecode(a:lines, {})

    for [l:filename, l:file] in items(get(l:json, 'files', {}))
        for l:error in get(l:file, 'errors', [])
            let l:output_line = {
            \   'filename': l:filename,
            \   'lnum': l:error.line,
            \   'text': l:error.msg,
            \   'type': toupper(l:error.severity[0]),
            \   'code': get(l:error, 'rule', ''),
            \}

            if has_key(l:error, 'range')
                let l:output_line.col = l:error.range.start.character
                let l:output_line.end_col = l:error.range.end.character
                let l:output_line.end_lnum = l:error.range.end.line
            endif

            call add(l:output, l:output_line)
        endfor
    endfor

    return l:output
endfunction

call ale#linter#Define('groovy', {
\   'name': 'npm-groovy-lint',
\   'executable': {b -> ale#Var(b, 'groovy_npmgroovylint_executable')},
\   'command': function('ale_linters#groovy#npmgroovylint#GetCommand'),
\   'callback': 'ale_linters#groovy#npmgroovylint#Handle',
\})
