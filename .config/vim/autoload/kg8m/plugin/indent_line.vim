vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: () => OnSource(),
  })
enddef

def OnSource(): void
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
