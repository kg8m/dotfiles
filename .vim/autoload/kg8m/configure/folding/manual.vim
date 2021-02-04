vim9script

def kg8m#configure#folding#manual#setup(): void
  augroup my_vimrc
    # https://vim.fandom.com/wiki/Keep_folds_closed_while_inserting_text
    autocmd InsertEnter * s:apply()
  augroup END
enddef

# Call this before saving session
def kg8m#configure#folding#manual#restore(): void
  if has_key(w:, "original_foldmethod")
    &l:foldmethod = w:original_foldmethod
    unlet w:original_foldmethod
  endif
enddef

def s:apply(): void
  if !has_key(w:, "original_foldmethod")
    w:original_foldmethod = &foldmethod
    setlocal foldmethod=manual
  endif
enddef
