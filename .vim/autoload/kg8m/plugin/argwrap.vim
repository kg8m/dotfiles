function kg8m#plugin#argwrap#configure() abort  " {{{
  nnoremap <Leader>a :ArgWrap<Cr>

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: "ArgWrap",
  \   hook_source: function("s:on_source"),
  \ })
endfunction  " }}}

function s:set_local_options() abort  " {{{
  if &filetype =~# '\v^(eruby|ruby)$'
    let b:argwrap_tail_comma_braces = "[{"
  elseif &filetype ==# "vim"
    let b:argwrap_tail_comma_braces = "[{"
    let b:argwrap_line_prefix = '\'
  endif
endfunction  " }}}

function s:on_source() abort  " {{{
  let g:argwrap_padded_braces = "{"

  augroup my_vimrc  " {{{
    autocmd FileType * call s:set_local_options()
  augroup END  " }}}

  call s:set_local_options()
endfunction  " }}}
