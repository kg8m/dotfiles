vim9script

def kg8m#plugin#choosewin#configure(): void  # {{{
  nmap <C-w>f <Plug>(choosewin)

  g:choosewin_overlay_enable          = v:false
  g:choosewin_overlay_clear_multibyte = v:false
  g:choosewin_blink_on_land           = v:false
  g:choosewin_statusline_replace      = v:true
  g:choosewin_tabline_replace         = v:false

  kg8m#plugin#configure({
    lazy:   v:true,
    on_map: "<Plug>(choosewin)",
  })
enddef  # }}}
