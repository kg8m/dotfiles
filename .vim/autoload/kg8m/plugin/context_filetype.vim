function kg8m#plugin#context_filetype#configure() abort  " {{{
  let s:context_filetype = {}
  let s:context_filetype.filetypes = {}
  let s:context_filetype.filetypes.for_js = [
  \   #{ start: '\<html`$', end: '^\s*`', filetype: 'html' },
  \   #{ start: '\<css`$', end: '^\s*`', filetype: 'css' },
  \ ]

  " For caw.vim and so on
  let g:context_filetype#filetypes = #{
  \   javascript: s:context_filetype.filetypes.for_js,
  \   typescript: s:context_filetype.filetypes.for_js,
  \ }
endfunction  " }}}
