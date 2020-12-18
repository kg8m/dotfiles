vim9script

def kg8m#plugin#easymotion#configure(): void  # {{{
  map <Leader>f <Plug>(easymotion-bd-fn)

  # Replace default `f` and `F`
  map f <Plug>(easymotion-fl)
  map F <Plug>(easymotion-Fl)

  g:EasyMotion_keys               = "FKLASDHGUIONMREWCVTYBX,.;J"
  g:EasyMotion_startofline        = v:false
  g:EasyMotion_do_shade           = v:false
  g:EasyMotion_do_mapping         = v:false
  g:EasyMotion_smartcase          = v:true
  g:EasyMotion_use_migemo         = v:true
  g:EasyMotion_use_upper          = v:true
  g:EasyMotion_enter_jump_first   = v:true
  g:EasyMotion_add_search_history = v:false

  kg8m#plugin#configure({
    lazy:   v:true,
    on_map: "<Plug>(easymotion-",
  })
enddef  # }}}
