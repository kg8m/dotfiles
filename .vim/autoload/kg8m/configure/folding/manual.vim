function kg8m#configure#folding#manual#setup() abort  " {{{
  augroup my_vimrc  " {{{
    " https://vim.fandom.com/wiki/Keep_folds_closed_while_inserting_text
    autocmd InsertEnter * call s:apply()
  augroup END  " }}}
endfunction  " }}}

" Call this before saving session
function kg8m#configure#folding#manual#restore() abort  " {{{
  if has_key(w:, "original_foldmethod")
    let &l:foldmethod = w:original_foldmethod
    unlet w:original_foldmethod
  endif
endfunction  " }}}

function s:apply() abort  " {{{
  if !has_key(w:, "original_foldmethod")
    let w:original_foldmethod = &foldmethod
    setlocal foldmethod=manual
  endif
endfunction  " }}}
