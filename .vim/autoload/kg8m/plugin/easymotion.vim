function kg8m#plugin#easymotion#configure() abort  " {{{
  map <Leader>f <Plug>(easymotion-bd-fn)

  " Replace default `f` and `F`
  map f <Plug>(easymotion-fl)
  map F <Plug>(easymotion-Fl)

  let g:EasyMotion_keys               = "FKLASDHGUIONMREWCVTYBX,.;J"
  let g:EasyMotion_startofline        = v:false
  let g:EasyMotion_do_shade           = v:false
  let g:EasyMotion_do_mapping         = v:false
  let g:EasyMotion_smartcase          = v:true
  let g:EasyMotion_use_migemo         = v:true
  let g:EasyMotion_use_upper          = v:true
  let g:EasyMotion_enter_jump_first   = v:true
  let g:EasyMotion_add_search_history = v:false

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: "<Plug>(easymotion-",
  \ })
endfunction  " }}}
