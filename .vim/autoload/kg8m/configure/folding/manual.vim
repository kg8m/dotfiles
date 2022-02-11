vim9script

export def Setup(): void
  augroup vimrc-configure-folding-manual
    autocmd!

    # https://vim.fandom.com/wiki/Keep_folds_closed_while_inserting_text
    autocmd InsertEnter * Apply()
  augroup END
enddef

# Call this before saving session
export def Restore(): void
  if has_key(w:, "original_foldmethod")
    &l:foldmethod = w:original_foldmethod
    unlet w:original_foldmethod
  endif
enddef

def Apply(): void
  if !has_key(w:, "original_foldmethod")
    w:original_foldmethod = &foldmethod
    setlocal foldmethod=manual
  endif
enddef
