vim9script

export def Configure(): void
  nnoremap <Leader>a :ArgWrap<CR>

  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: "ArgWrap",
    hook_source: () => OnSource(),
  })
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

def OnSource(): void
  g:argwrap_padded_braces = "{"

  augroup vimrc-plugin-argwrap
    autocmd!
    autocmd FileType * SetLocalOptions()
  augroup END

  SetLocalOptions()
enddef
