vim9script

def kg8m#plugin#jplus#configure(): void
  # Remove line-connectors with `J`
  nmap <S-j> <Plug>(jplus)
  xmap <S-j> <Plug>(jplus)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { nx: "<Plug>(jplus)" },
  })
enddef
