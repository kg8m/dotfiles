vim9script

def kg8m#plugin#winresizer#configure(): void
  g:winresizer_start_key = "<C-w><C-e>"

  kg8m#plugin#configure({
    lazy:   true,
    on_map: [["n", g:winresizer_start_key]],
  })
enddef
