function kg8m#plugin#findent#configure() abort  " {{{
  let g:findent#enable_messages = v:false
  let g:findent#enable_warnings = v:false

  augroup my_vimrc  " {{{
    autocmd FileType * call s:run()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: "Findent",
  \ })
endfunction  " }}}

function s:run() abort  " {{{
  if &filetype !=# "startify"
    Findent
  endif
endfunction  " }}}
