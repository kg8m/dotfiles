vim9script

def kg8m#plugin#jplus#configure(): void
  # Remove line-connectors with `J`
  nmap J <Plug>(jplus)
  xmap J <Plug>(jplus)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { nx: "<Plug>(jplus)" },
  })
enddef
