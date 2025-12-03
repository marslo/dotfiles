#!/usr/bin/env bash
#=============================================================================
#     FileName : font-patcher.sh
#       Author : marslo.jiao@gmail.com
#      Created : 2024-04-15 19:31:20
#   LastChange : 2024-04-15 19:31:20
#=============================================================================

_font_patcher() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="
     -h
     --help
     -v
     --version
     -s
     --mono
     --use-single-width-glyphs
     --variable-width-glyphs
     --debug
     -q
     --quiet
     --careful
     -ext
     --extension
     -out
     --outputdir
     --makegroups
     -c
     --complete
     --codicons
     --fontawesome
     --fontawesomeext
     --fontlogos
     --material
     --mdi
     --octicons
     --powersymbols
     --pomicons
     --powerline
     --powerlineextra
     --weather
     --boxdrawing
     --configfile
     --custom CUSTOM
     --dry
     --glyphdir
     --has-no-italic
     -l
     --adjust-line-height
     --metrics
     --name
     --postprocess
     --removeligs
     --removeligatures
     --xavgcharwidth
     --progressbars
     --no-progressbars"

  if [[ "$cur" =~ ^-|\+ ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
    return 0
  fi

  return 0
}

if [[ $- =~ i ]]; then
  complete -o default -o bashdefault -F _font_patcher font-patcher
fi
