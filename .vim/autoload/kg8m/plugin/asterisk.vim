function kg8m#plugin#asterisk#configure() abort  " {{{
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["nv", "<Plug>(asterisk-"]],
  \ })
endfunction  " }}}
