vim9script

export def OnSource(): void
  g:argwrap_padded_braces = "{"

  augroup vimrc-plugin-argwrap
    autocmd!
    autocmd FileType * SetLocalOptions()
  augroup END

  SetLocalOptions()
enddef

def SetLocalOptions(): void
  if &filetype =~# '\v^%(eruby|ruby)$'
    b:argwrap_tail_comma_braces = "[{"
  elseif &filetype =~# '\v^%(javascript|typescript)%(react)?$'
    b:argwrap_tail_comma_braces = "[{"
  elseif &filetype ==# "vim"
    b:argwrap_tail_comma_braces = "[{"

    if getline(1) ==# "vim9script"
      b:argwrap_line_prefix = ""
    else
      b:argwrap_line_prefix = '\ '
    endif
  endif
enddef
