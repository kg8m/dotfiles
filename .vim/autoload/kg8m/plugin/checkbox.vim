function kg8m#plugin#checkbox#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call checkbox#ToggleCB()<Cr>
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_func: "checkbox#",
  \ })
endfunction  " }}}
