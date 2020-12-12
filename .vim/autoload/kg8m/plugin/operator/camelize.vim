function kg8m#plugin#operator#camelize#configure() abort  " {{{
  vmap <Leader>C <Plug>(operator-camelize)
  vmap <Leader>c <Plug>(operator-decamelize)

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [
  \     ["v", "<Plug>(operator-camelize)"],
  \     ["v", "<Plug>(operator-decamelize)"]
  \   ],
  \ })
endfunction  " }}}
