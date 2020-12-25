vim9script

def kg8m#plugin#argwrap#configure(): void  # {{{
  nnoremap <Leader>a :ArgWrap<CR>

  kg8m#plugin#configure({
    lazy:   v:true,
    on_cmd: "ArgWrap",
    hook_source: function("s:on_source"),
  })
enddef  # }}}

def s:set_local_options(): void  # {{{
  if &filetype =~# '\v^(eruby|ruby)$'
    b:argwrap_tail_comma_braces = "[{"
  elseif &filetype ==# "vim"
    b:argwrap_tail_comma_braces = "[{"
    b:argwrap_line_prefix = '\'
  endif
enddef  # }}}

def s:on_source(): void  # {{{
  g:argwrap_padded_braces = "{"

  augroup my_vimrc  # {{{
    autocmd FileType * s:set_local_options()
  augroup END  # }}}

  s:set_local_options()
enddef  # }}}
