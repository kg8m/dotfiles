vim9script

def kg8m#plugin#operator#replace#configure(): void
  xmap r <Plug>(operator-replace)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { x: "<Plug>(operator-replace)" },
  })
enddef
