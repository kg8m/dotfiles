function kg8m#plugin#jplus#configure() abort  " {{{
  " Remove line-connectors with `J`
  nmap J <Plug>(jplus)
  vmap J <Plug>(jplus)

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["nv", "<Plug>(jplus)"]],
  \ })
endfunction  " }}}
