function kg8m#plugin#sequence#configure() abort  " {{{
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["vn", "<Plug>Sequence"]],
  \ })
endfunction  " }}}
