vim9script

def kg8m#plugin#asterisk#configure(): void  # {{{
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)

  kg8m#plugin#configure({
    lazy:   v:true,
    on_map: [["nv", "<Plug>(asterisk-"]],
  })
enddef  # }}}
