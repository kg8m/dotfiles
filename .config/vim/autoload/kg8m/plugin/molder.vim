vim9script

export def Configure(): void
  nnoremap <silent> <Leader>e :call <SID>Run()<CR>

  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: () => OnSource(),
  })
enddef

def Run(): void
  kg8m#plugin#EnsureSourced("vim-molder")

  if expand("%")->empty()
    edit .
  else
    edit %:h
  endif
enddef

def SetupBuffer(): void
  # Cancel molder
  nnoremap <buffer> q     <C-o>
  nnoremap <buffer> <C-c> <C-o>
enddef

def OnSource(): void
  g:molder_show_hidden = true

  augroup vimrc-plugin-molder
    autocmd!
    autocmd FileType molder SetupBuffer()
  augroup END
enddef
