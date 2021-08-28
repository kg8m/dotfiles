vim9script

def kg8m#plugin#operator#camelize#configure(): void
  xmap <Leader>C <Plug>(operator-camelize)
  xmap <Leader>c <Plug>(operator-decamelize)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { x: ["<Plug>(operator-camelize)", "<Plug>(operator-decamelize)"] },
  })
enddef
