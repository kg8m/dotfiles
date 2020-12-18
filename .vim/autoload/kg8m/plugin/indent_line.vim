vim9script

def kg8m#plugin#indent_line#configure(): void  # {{{
  kg8m#configure#conceal()

  g:indentLine_char            = "|"
  g:indentLine_faster          = v:true
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
enddef  # }}}
