vim9script

import autoload "kg8m/plugin.vim"

export def OnSource(): void
  g:molder_show_hidden = true

  augroup vimrc-plugin-molder
    autocmd!
    autocmd FileType molder SetupBuffer()
  augroup END
enddef

export def Run(): void
  if expand("%")->empty()
    edit .
  else
    const filename = expand("%:t")
    timer_start(10, (_) => search($'\V\^{filename}\$'))

    edit %:h
  endif
enddef

def SetupBuffer(): void
  # Cancel molder
  nnoremap <buffer> q     <C-o>
  nnoremap <buffer> <C-c> <C-o>
enddef

plugin.EnsureSourced("vim-molder")
