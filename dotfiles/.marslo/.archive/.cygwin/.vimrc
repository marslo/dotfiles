set nocompatible
syntax enable on
filetype plugin indent on
let mapleader=","

nmap <leader>v :e ~/.cygwin/.vimrc<CR>
autocmd! bufwritepost ~/.cygwin/.vimrc source %

set ttyfast                                                       " Enable fast terminal connection.
set clipboard+=unnamed                                            " Copy the content to system clipboard by using y/p
set clipboard+=unnamedplus

set ttyfast                                                       " Enable fast terminal connection.
set iskeyword-=.
set autochdir
set fileencodings=utf-8,ucs-bom,gbk,cp936,gb2312,gb18030            " Code Format
set termencoding=utf-8
set encoding=utf-8                                                  " Input Chinese (=cp936)
set fileencoding=utf-8
let &termencoding=&encoding
set selection=exclusive                                             " Mouse Settings
set selectmode=mouse,key
set nobackup noswapfile nowritebackup noundofile noendofline
set number                                                          " Number: line number
set report=0
set autoread                                                        " Set auto read when a file is changed by outside
set showmatch                                                       " Show matching bracets (shortly jump to the other bracets)
set matchtime=1                                                     " The shortly time
set tabstop=2                                                       " Tab width
set softtabstop=2                                                   " Width for backspace
set shiftwidth=2                                                    " The tab width by using >> & <<
set autoindent smartindent expandtab
set cindent
set cinoptions=(0,u0,U0
set smarttab                                                        " Smarttab: the width of <Tab> in first line would refer to 'Shiftwidth' parameter
set linebreak
set nomodifiable
set write
set incsearch hlsearch ignorecase smartcase                         " Search
set magic                                                           " Regular Expression
set linespace=0
set wildmenu
set wildmode=longest,list,full                                      " Completion mode that is used for the character
set noerrorbells novisualbell                                       " + Turn off
set t_vb=                                                           " + error beep/flash
" set list listchars=tab:\ \ ,tab:?,trail:?,extends:?,precedes:?,nbsp:?,eol:?
set list
set listchars=tab:\?\ ,trail:?,extends:?,precedes:?,nbsp:?
set cursorline                                                      " Highlight the current line
set guicursor=a:hor1
set guicursor+=i-r-ci-cr-o:hor2-blinkon0
set virtualedit=onemore                                             " Allow for cursor beyond last character
set scrolloff=3                                                     " Scroll settings
set sidescroll=1
set sidescrolloff=5
set imcmdline                                                       " Fix context menu messing
set complete+=kspell
set completeopt=longest,menuone                                     " Supper Tab
set foldenable                                                      " Enable Fold
set foldcolumn=1
set foldexpr=1                                                      " Shown line number after fold
set foldlevel=100                                                   " Not fold while VIM set up
set shortmess+=filmnrxoOtT                                          " Abbrev. of messages (avoids 'hit enter')
set viewoptions=folds
set backspace=indent,eol,start                                      " Make backspace h, l, etc wrap to
set whichwrap+=<,>,h,l
set go+=a                                                           " Visual selection automatically copied to the clipboard
set hidden                                                          " Switch between buffers with unsaved change
set equalalways
set formatoptions=tcrqn
set formatoptions+=rnmMB                                            " Remove the backspace for combine lines (Only for chinese)
set matchpairs+=<:>
" set autowrite
if has('cmdline_info')
  set ruler                                                         " ruler: Show Line and colum number
  set showcmd                                                       " Show (partial) command in status line
endif
if has('statusline')
  set laststatus=2                                                  " Set status bar
  set statusline=%#User2#%m%r%*\ %F\ %y,%{&fileformat}
  " set statusline+=\ %{fugitive#statusline()}
  set statusline+=%=\ %-{strftime(\"%H:%M\ %d/%m/%Y\")}\ %b[A],0x%B\ %c%V,%l/%L\ %1*--%n%%--%*\ %p%%\ |
endif
" set synmaxcol=128
" set binary
set exrc
set secure



noremap <F1> <ESC>
imap <F1> <ESC>a
map ,bd :bd<CR>
map <C-k> <C-w>k
map <C-j> <C-w>j
map <C-a> <ESC>^
imap <C-a> <ESC>I
map <C-e> <ESC>$
imap <C-e> <ESC>A
inoremap <M-f> <ESC><Space>Wi
inoremap <M-b> <ESC>Bi
inoremap <M-d> <ESC>cW
nnoremap Y y$
nnoremap <Del> "_x
xnoremap <Del> "_d

nmap zdb :%s/\s\+$//<CR>
nmap zhh :%s/^\s\+//<CR>
nmap zmm :g/^/ s//\=line('.').' '/<CR>
nmap zws :g/^\s*$/d<CR>

if exists('$TMUX')
  set term=screen-256color
endif

if has('gui_running') || 'xterm-256color' == $TERM
  if has('win32') || has('win64')
    let vsp='C:\Users\marslo\.cygwin\.vim\bundle\vim-colors-solarized'
  else
    let vsp=$HOME . '/.cygwin/.vim/bundle/vim-colors-solarized'
  endif

  set rtp+=~/.cygwin/.vim/bundle/vim-colors-solarized
  if empty(glob(expand(vsp)))
    execute 'silent !git clone https://github.com/altercation/vim-colors-solarized.git "' . expand(vsp) '"'
  endif

  set t_Co=256
  set background=dark
  let g:solarized_termcolors=256
  colorscheme solarized
  let psc_style='cool'
  set guifont=Monaco:h16
  set lines=28
  set columns=100

else

  set t_Co=8
  set t_Sb=^[[4%dm
  set t_Sf=^[[3%dm

  " marslo256.vim: https://github.com/Marslo/marslo.vim
  hi SpecialKey           ctermfg=darkgreen
  hi NonText              cterm=NONE          ctermfg=239
  hi Directory            ctermfg=63
  hi ErrorMsg             cterm=NONE          ctermfg=red         ctermbg=0
  hi IncSearch            cterm=NONE          ctermfg=yellow      ctermbg=green
  hi Search               cterm=NONE          ctermfg=grey        ctermbg=blue
  hi MoreMsg              ctermfg=darkgreen
  hi ModeMsg              cterm=NONE          ctermfg=brown
  hi Question             ctermfg=green
  hi StatusLine           cterm=NONE          ctermfg=darkgray    ctermbg=black
  hi StatusLineNC         cterm=NONE
  hi VertSplit            cterm=NONE
  hi Title                ctermfg=5
  hi Visual               cterm=underline     ctermbg=NONE
  hi VisualNOS            cterm=underline
  hi WarningMsg           ctermfg=yellow      ctermbg=black
  hi WildMenu             ctermfg=0           ctermbg=3
  hi Folded               ctermfg=darkgrey    ctermbg=NONE
  hi FoldColumn           ctermfg=darkgrey    ctermbg=NONE
  hi DiffAdd              cterm=NONE          ctermbg=56          ctermfg=255
  hi DiffDelete           cterm=NONE          ctermbg=239
  hi DiffAdded            ctermbg=93
  hi DiffRemoved          ctermbg=129
  hi DiffChange           cterm=bold          ctermbg=99          ctermfg=255
  hi DiffText             cterm=NONE          ctermbg=196
  hi Pmenu                ctermfg=208         ctermbg=NONE
  hi PmenuSel             ctermfg=154
  hi Identifier           ctermfg=149
  hi Cursor               cterm=underline     term=underline
  hi MatchParen           cterm=inverse       term=inverse
  hi LineNr               ctermfg=239         ctermbg=none
  hi CursorLine           cterm=NONE
  hi String               ctermfg=82
  hi Entity               ctermfg=166
  hi Support              ctermfg=202
  hi CursorLineNr         ctermbg=NONE        ctermfg=118         term=bold
  hi Comment              ctermfg=239
  hi Constant             ctermfg=113
  """" Key words (while, if, else, for, in)
  hi Statement            ctermfg=red
  """" #! color
  hi PreProc              ctermfg=red
  """" classname, <key>, <Groupname> color
  hi Type                 ctermfg=106
  hi Special              ctermfg=221
  hi Underlined           cterm=underline     ctermfg=5
  hi Ignore               cterm=NONE          ctermfg=7       ctermfg=darkgrey
  hi Error                cterm=NONE          ctermfg=7       ctermbg=1
  " HTML
  hi htmlTag              ctermfg=244
  hi htmlEndTag           ctermfg=244
  hi htmlArg              ctermfg=203
  hi htmlValue            ctermfg=187
  hi htmlTitle            ctermfg=184         ctermbg=NONE
  hi htmlTagName          ctermfg=69
  hi htmlString           ctermfg=113
  " NERDTree
  hi treeCWD              ctermfg=180
  hi treeClosable         ctermfg=174
  hi treeOpenable         ctermfg=150
  hi treePart             ctermfg=244
  hi treeDirSlash         ctermfg=244
  hi treeLink             ctermfg=182

  hi Boolean              ctermfg=196
  hi Function             ctermfg=105
  hi Structure            ctermfg=202
  hi Define               ctermfg=179
  hi Conditional          ctermfg=190
  hi Operator             ctermfg=208

  hi rubyIdentifier       ctermfg=9
endif
