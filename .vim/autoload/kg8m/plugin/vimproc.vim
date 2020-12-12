function kg8m#plugin#vimproc#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   build:   "make",
  \   on_func: "vimproc#",
  \ })
endfunction  " }}}
