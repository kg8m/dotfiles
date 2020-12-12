function kg8m#plugin#rainbow_csv#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd BufNewFile,BufRead *.csv set filetype=csv
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:  v:true,
  \   on_ft: "csv",
  \ })
endfunction  " }}}
