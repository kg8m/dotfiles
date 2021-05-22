vim9script

def kg8m#plugin#asterisk#configure(): void
  map <expr> *  <SID>with_notify("<Plug>(asterisk-z*)")
  map <expr> #  <SID>with_notify("<Plug>(asterisk-z#)")
  map <expr> g* <SID>with_notify("<Plug>(asterisk-gz*)")
  map <expr> g# <SID>with_notify("<Plug>(asterisk-gz#)")

  kg8m#plugin#configure({
    lazy:   true,
    on_map: [["nv", "<Plug>(asterisk-"]],
  })
enddef

def s:with_notify(mapping: string): string
  timer_start(100, (_) => kg8m#events#notify_search_start())
  return mapping
enddef
