vim9script

def kg8m#plugin#sequence#configure(): void
  map <Leader>+ <Plug>SequenceV_Increment
  map <Leader>- <Plug>SequenceV_Decrement

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { x: "<Plug>Sequence" },
  })
enddef
