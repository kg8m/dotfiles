vim9script

export def OnSource(): void
  g:unite_winheight = "100%"

  augroup vimrc-plugin-unite
    autocmd!
    autocmd FileType unite SetupBuffer()
  augroup END
enddef

def SetupBuffer(): void
  EnableHighlightingCursorline()
  DisableDefaultMappings()
enddef

def EnableHighlightingCursorline(): void
  setlocal cursorlineopt=both
enddef

def DisableDefaultMappings(): void
  if !!mapcheck("<S-n>", "n")
    nunmap <buffer> <S-n>
  endif
enddef
