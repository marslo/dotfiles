" =============================================================================
"      FileName : .vimrc
"        Author : marslo.jiao@gmail.com
"       Created : 2010-10
"       Version : 2.0.1
"    LastChange : 2024-02-22 15:29:33
" =============================================================================

runtime macros/matchit.vim
runtime defaults.vim
let performance_mode = 1
set nocompatible
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

if has('win32') || has('win64') | source $HOME\.vim\autoload\plug.vim | endif
set runtimepath+=~/.vim/plugged

if has('macunix') || has( 'win32' ) || has( 'win64' )
  set spellcapcheck=1
else                                                                " if has('unix')
  set spellcapcheck=0
endif

if has('macunix')
  set shell=/usr/local/bin/bash
  let g:gitgutter_git_executable = '/usr/local/bin/git'
elseif has('win32') || has('win64')
  set shell='c:\iMarslo\myprograms\Git\bin\bash.exe'
  let g:gitgutter_git_executable = 'c:\iMarslo\myprograms\Git\bin\git.exe'
else                                                                " linux/wsl
  set shell=/usr/bin/bash
  let g:gitgutter_git_executable = '/usr/bin/git'
endif

if filereadable( '/usr/local/opt/fzf' )
  set runtimepath+=/usr/local/opt/fzf
elseif filereadable( '~/.marslo/bin/fzf' )
  set runtimepath+=~/.marslo/bin/fzf
endif

if has( 'nvim' )
  set viminfo=%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.nviminfo
  if empty( glob('~/.vim/undo/nundo')  )     | execute 'silent !mkdir -p ~/.vim/undo/nundo'    | endif
else
  if version > 74399 | set cryptmethod=blowfish2 | endif
  set viminfo=%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.viminfo
  if empty( glob('$HOME/.vim/undo/undo' )  ) | execute 'silent !mkdir -p $HOME/.vim/undo/undo' | endif
  set ttymouse=xterm2
endif
if empty( glob('$HOME/.vim/cache/') )        | execute 'silent !mkdir -p $HOME/.vim/cache'     | endif

source ~/.marslo/vimrc.d/extension
if has( 'vim' ) | source ~/.marslo/vimrc.d/extra-extension | endif
source ~/.marslo/vimrc.d/functions
source ~/.marslo/vimrc.d/cmds
source ~/.marslo/vimrc.d/theme
source ~/.marslo/vimrc.d/settings
source ~/.marslo/vimrc.d/shortcuts
source ~/.marslo/vimrc.d/autocmd
source ~/.marslo/vimrc.d/highlight

if IsWSL() != 1 && ! has('macunix') | source ~/.marslo/vimrc.d/unix | endif
if IsWSL() == 1
  set clipboard^=unnamed
  set clipboard^=unnamedplus
else
  set clipboard+=unnamed
  set clipboard+=unnamedplus
endif

if empty( glob('$HOME/.vim/autoload/plug.vim') ) || empty( glob($VIM . 'autoload\plug.vim') )
  execute 'silent exec "GetPlug"'
endif

" vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=vim:foldmethod=marker:foldmarker="\ **************************************************************/,"\ /**************************************************************
