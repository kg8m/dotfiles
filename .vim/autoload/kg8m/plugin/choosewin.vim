function kg8m#plugin#choosewin#configure() abort  " {{{
  nmap <C-w>f <Plug>(choosewin)

  let g:choosewin_overlay_enable          = v:false
  let g:choosewin_overlay_clear_multibyte = v:false
  let g:choosewin_blink_on_land           = v:false
  let g:choosewin_statusline_replace      = v:true
  let g:choosewin_tabline_replace         = v:false

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: "<Plug>(choosewin)",
  \ })
endfunction  " }}}
