vim9script

import autoload "kg8m/configure.vim"

export def OnSource(): void
  configure.Conceal()

  g:indentLine_char            = "|"
  g:indentLine_faster          = true
  g:indentLine_concealcursor   = &concealcursor
  g:indentLine_conceallevel    = &conceallevel
  g:indentLine_fileTypeExclude = [
    "",
    "diff",
    "startify",
    "unite",
  ]
  g:indentLine_bufTypeExclude = [
    "help",
    "terminal",
  ]
enddef
