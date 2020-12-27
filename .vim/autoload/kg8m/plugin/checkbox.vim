vim9script

def kg8m#plugin#checkbox#configure(): void  # {{{
  augroup my_vimrc  # {{{
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call checkbox#ToggleCB()<CR>
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:    true,
    on_func: "checkbox#",
  })
enddef  # }}}
