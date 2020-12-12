function kg8m#util#auto_reload#setup() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd VimEnter * call timer_start(1000, { -> s:checktime() }, #{ repeat: -1 })
  augroup END  " }}}
endfunction  " }}}

function s:checktime() abort  " {{{
  try
    " `checktime` is not available in Command Line mode
    if !getcmdwintype()->empty()
      return
    endif

    checktime
  " Sometimes `checktime` raise an error
  "   - e.g., E565: "Not allowed to change text or change window" when using vim-sandwich
  catch /^Vim\%((\a\+)\)\=:E565:/
    " Do nothing
  endtry
endfunction  " }}}
