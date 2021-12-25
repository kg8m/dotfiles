vim9script

def kg8m#plugin#stay#configure(): void
  set viewoptions=cursor,folds

  augroup vimrc-plugin-stay
    autocmd!
    autocmd User BufStaySavePre kg8m#configure#folding#manual#restore()
  augroup END
enddef
