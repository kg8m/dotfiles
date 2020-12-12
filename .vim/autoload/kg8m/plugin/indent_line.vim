function kg8m#plugin#indent_line#configure() abort  " {{{
  call kg8m#configure#conceal()

  let g:indentLine_char            = "|"
  let g:indentLine_faster          = v:true
  let g:indentLine_concealcursor   = &concealcursor
  let g:indentLine_conceallevel    = &conceallevel
  let g:indentLine_fileTypeExclude = [
  \   "",
  \   "diff",
  \   "startify",
  \   "unite",
  \ ]
  let g:indentLine_bufTypeExclude = [
  \   "help",
  \   "terminal",
  \ ]
endfunction  " }}}
