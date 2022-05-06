vim9script

export def Configure(): void
  augroup vimrc-plugin-checkbox
    autocmd!
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call <SID>Run()<CR>
  augroup END

  kg8m#plugin#Configure({
    lazy: true,
  })
enddef

def Run(): void
  kg8m#plugin#EnsureSourced("vim-checkbox")
  checkbox#ToggleCB()
enddef
