vim9script

export def OnSource(): void
  g:zenspace#default_mode = "on"
enddef

export def OnPostSource(): void
  zenspace#update()
enddef
