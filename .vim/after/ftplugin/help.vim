" https://thinca.hatenablog.com/entry/20110903/1314982646
function! s:setup_writing_help(...) abort  " {{{
  if &buftype !=# "help"
    setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78

    if exists("+colorcolumn")
      setlocal colorcolumn=+1
    endif

    if has("conceal")
      setlocal conceallevel=0
    endif
  endif
endfunction  " }}}

call timer_start(200, function("s:setup_writing_help"))
