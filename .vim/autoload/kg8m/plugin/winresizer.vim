function kg8m#plugin#winresizer#configure() abort  " {{{
  let g:winresizer_start_key = "<C-w><C-e>"

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["n", g:winresizer_start_key]],
  \ })
endfunction  " }}}
