function kg8m#plugin#jasentence#configure() abort  " {{{
  let g:jasentence_endpat = '[。．？！!?]\+'

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["nv", "("], ["nv", ")"], ["o", "s"]],
  \ })
endfunction  " }}}
