vim9script

def kg8m#plugin#operator#camelize#configure(): void
  xmap <Leader>C <Plug>(operator-camelize)
  xmap <Leader>c <Plug>(operator-decamelize)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: [
      ["v", "<Plug>(operator-camelize)"],
      ["v", "<Plug>(operator-decamelize)"]
    ],
  })
enddef
