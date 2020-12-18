vim9script

def kg8m#plugin#checkbox#configure(): void  # {{{
  augroup my_vimrc  # {{{
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call checkbox#ToggleCB()<Cr>
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:    v:true,
    on_func: "checkbox#",
  })
enddef  # }}}
