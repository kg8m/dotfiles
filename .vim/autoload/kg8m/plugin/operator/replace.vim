function kg8m#plugin#operator#replace#configure() abort  " {{{
  map r <Plug>(operator-replace)

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   depends: ["vim-operator-user"],
  \   on_map:  [["nv", "<Plug>(operator-replace)"]],
  \ })
endfunction  " }}}
