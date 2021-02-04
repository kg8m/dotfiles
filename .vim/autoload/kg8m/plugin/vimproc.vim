vim9script

def kg8m#plugin#vimproc#configure(): void
  kg8m#plugin#configure({
    lazy:    true,
    build:   "make",
    on_func: "vimproc#",
  })
enddef
