" =============================================================================
"      FileName : .vimrc
"        Author : marslo.jiao@gmail.com
"       Created : 2010-10
"       Version : 2.0.2
"    LastChange : 2025-11-04 02:01:53
" =============================================================================

runtime macros/matchit.vim
runtime defaults.vim
let performance_mode = 1
" set nocompatible
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

source $HOME/.marslo/vimrc.d/os

if IsWindows() | source $HOME\.vim\autoload\plug.vim | endif
set runtimepath+=~/.vim/plugged

if IsMac() || IsWindows()
  set spellcapcheck=1
else                                                                " if has('unix')
  set spellcapcheck=0
endif

" python, git, shell environment
if IsGitBash() || IsNuShell()
  let g:python3_host_prog        = 'c:\iMarslo\myprograms\Python312\python.exe'
  let g:gitgutter_git_executable = '/mingw64/bin/git'
elseif IsWindows()
  let g:python3_host_prog        = 'c:\iMarslo\myprograms\Python312\python.exe'
  let g:gitgutter_git_executable = 'c:\iMarslo\myprograms\Git\bin\git.exe'
  " set shell=C:\iMarslo\myprograms\Git\bin\bash.exe
else
  let g:python3_host_prog        = expand(trim( system('command -v python3') ))
  let g:gitgutter_git_executable = expand(trim( system('command -v git') ))
  set shell=/bin/bash
endif

" set shell=/opt/homebrew/bin/bash
if IsMac() && executable('brew')
  let s:brewBash = expand(trim( system('brew --prefix bash') )) . '/bin/bash'
else
  let s:brewBash = expand(trim( system('command -v bash') ))
endif
if filereadable( s:brewBash ) | let &shell = s:brewBash | endif
if executable( 'bash' )       | set shellcmdflag=-c     | endif     " let &shellcmdflag = '-c'

" set rtp+=/opt/homebrew/opt/fzf
if filereadable( '$HOME/.marslo/bin/fzf' ) | set runtimepath+=$HOME/.marslo/bin/fzf | endif
if IsMac() && executable('brew')
  let s:fzfBash = expand(trim( system('brew --prefix fzf') ))
  if isdirectory( s:fzfBash ) | let &runtimepath .= ',' . s:fzfBash | endif
endif

if has( 'nvim' ) | let g:loaded_perl_provider = 0 | endif
if has( 'nvim' )
  set viminfo=%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.nviminfo
else
  if v:version > 74399 | set cryptmethod=blowfish2 | endif
  set viminfo=%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.viminfo
  set ttymouse=xterm2
endif
if empty( glob('~/.vim/cache/') ) | execute 'silent !mkdir -p ~/.vim/cache' | endif

source ~/.marslo/vimrc.d/extension
if has( 'vim' ) | source ~/.marslo/vimrc.d/extra-extension | endif
source ~/.marslo/vimrc.d/functions
source ~/.marslo/vimrc.d/cmds
source ~/.marslo/vimrc.d/theme
source ~/.marslo/vimrc.d/settings
source ~/.marslo/vimrc.d/shortcuts
source ~/.marslo/vimrc.d/autocmd
source ~/.marslo/vimrc.d/highlight

if ! IsWSL() && ! IsMac() | source ~/.marslo/vimrc.d/unix | endif
if IsWSL()
  set clipboard=unnamed
  set clipboard=unnamedplus
else
  set clipboard+=unnamed
  set clipboard+=unnamedplus
endif

if has( 'persistent_undo' )
  if has('nvim')
    let target_path = expand( '~/.vim/undo' )
    set undodir=expand('~/.vim/undo')
  else
    let target_path = expand( '~/.vim/undo/vundo' )
  endif
  if !isdirectory( target_path )
    call system( 'mkdir -p ' . target_path )
  endif
  set undofile
  let &undodir=target_path
endif

if empty( glob('$HOME/.vim/autoload/plug.vim') ) || empty( glob($VIM . 'autoload\plug.vim') )
  execute 'silent exec "GetPlug"'
endif

" vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=vim:
