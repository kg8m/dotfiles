vim9script

def kg8m#plugin#operator#replace#configure(): void  # {{{
  map r <Plug>(operator-replace)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: [["nv", "<Plug>(operator-replace)"]],
  })
enddef  # }}}
