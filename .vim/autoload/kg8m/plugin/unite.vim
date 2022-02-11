vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: "Unite",
    hook_source: () => OnSource(),
  })
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

def OnSource(): void
  g:unite_winheight = "100%"

  augroup vimrc-plugin-unite
    autocmd!
    autocmd FileType unite SetupBuffer()
  augroup END
enddef
