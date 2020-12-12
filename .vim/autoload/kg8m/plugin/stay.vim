function kg8m#plugin#stay#configure() abort  " {{{
  set viewoptions=cursor,folds

  augroup my_vimrc  " {{{
    autocmd User BufStaySavePre call kg8m#configure#folding#manual#restore()
  augroup END  " }}}
endfunction  " }}}
