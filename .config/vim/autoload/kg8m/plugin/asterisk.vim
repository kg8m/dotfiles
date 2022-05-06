vim9script

export def Configure(): void
  map <expr> *  <SID>WithNotify("<Plug>(asterisk-z*)")
  map <expr> #  <SID>WithNotify("<Plug>(asterisk-z#)")
  map <expr> g* <SID>WithNotify("<Plug>(asterisk-gz*)")
  map <expr> g# <SID>WithNotify("<Plug>(asterisk-gz#)")

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(asterisk-" },
  })
enddef

def WithNotify(mapping: string): string
  timer_start(100, (_) => kg8m#events#NotifySearchStart())
  return mapping
enddef
