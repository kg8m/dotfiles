function kg8m#plugin#unite#configure() abort  " {{{
  let g:unite_winheight = "100%"

  augroup my_vimrc  " {{{
    autocmd FileType unite call s:setup_buffer()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_cmd:  "Unite",
  \   on_func: "unite#",
  \ })
endfunction  " }}}

function s:setup_buffer() abort  " {{{
  call s:enable_highlighting_cursorline()
  call s:disable_default_mappings()
endfunction  " }}}

function s:enable_highlighting_cursorline() abort  " {{{
  setlocal cursorlineopt=both
endfunction  " }}}

function s:disable_default_mappings() abort  " {{{
  if mapcheck("<S-n>", "n")
    nunmap <buffer> <S-n>
  endif
endfunction  " }}}
