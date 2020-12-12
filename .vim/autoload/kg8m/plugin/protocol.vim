function kg8m#plugin#protocol#configure() abort  " {{{
  " Disable netrw.vim
  let g:loaded_netrw             = v:true
  let g:loaded_netrwPlugin       = v:true
  let g:loaded_netrwSettings     = v:true
  let g:loaded_netrwFileHandlers = v:true

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_path: '^https\?://',
  \ })
endfunction  " }}}
