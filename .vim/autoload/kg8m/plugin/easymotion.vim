vim9script

def kg8m#plugin#easymotion#configure(): void  # {{{
  map <Leader>f <Plug>(easymotion-bd-fn)

  # Replace default `f` and `F`
  map f <Plug>(easymotion-fl)
  map F <Plug>(easymotion-Fl)

  g:EasyMotion_keys               = "FKLASDHGUIONMREWCVTYBX,.;J"
  g:EasyMotion_startofline        = false
  g:EasyMotion_do_shade           = false
  g:EasyMotion_do_mapping         = false
  g:EasyMotion_smartcase          = true
  g:EasyMotion_use_migemo         = true
  g:EasyMotion_use_upper          = true
  g:EasyMotion_enter_jump_first   = true
  g:EasyMotion_add_search_history = false

  kg8m#plugin#configure({
    lazy:   true,
    on_map: "<Plug>(easymotion-",
  })
enddef  # }}}
