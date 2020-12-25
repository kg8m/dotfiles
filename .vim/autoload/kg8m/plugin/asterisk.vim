vim9script

var s:is_initialized = v:false

def kg8m#plugin#asterisk#configure(): void  # {{{
  map <expr> *  <SID>with_notify("<Plug>(asterisk-z*)")
  map <expr> #  <SID>with_notify("<Plug>(asterisk-z#)")
  map <expr> g* <SID>with_notify("<Plug>(asterisk-gz*)")
  map <expr> g# <SID>with_notify("<Plug>(asterisk-gz#)")

  kg8m#plugin#configure({
    lazy:   v:true,
    on_map: [["nv", "<Plug>(asterisk-"]],
  })
enddef  # }}}

def s:with_notify(mapping: string): string  # {{{
  if !s:is_initialized
    augroup my_vimrc  # {{{
      autocmd User search_start silent
    augroup END  # }}}

    s:is_initialized = v:true
  endif

  timer_start(100, { -> execute("doautocmd <nomodeline> User search_start") })
  return mapping
enddef  # }}}
