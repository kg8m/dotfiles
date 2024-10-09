vim9script

export def Run(): void
  augroup vimrc-configure-filetypes-ruby
    autocmd!
    autocmd FileType Gemfilelock SetupGemfilelockBuffer()
  augroup END
enddef

def SetupGemfilelockBuffer(): void
  setlocal foldmethod=indent
enddef
