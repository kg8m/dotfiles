vim9script

def kg8m#plugin#choosewin#configure(): void
  nmap <C-w>f <Plug>(choosewin)

  g:choosewin_overlay_enable          = false
  g:choosewin_overlay_clear_multibyte = false
  g:choosewin_blink_on_land           = false
  g:choosewin_statusline_replace      = true
  g:choosewin_tabline_replace         = false

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { n: "<Plug>(choosewin)" },
  })
enddef
