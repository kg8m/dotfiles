vim9script

export def OnSource(): void
  kg8m#configure#Conceal()

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
