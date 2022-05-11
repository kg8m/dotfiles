vim9script

# https://thinca.hatenablog.com/entry/20110903/1314982646
export def SetupWriting(): void
  if &buftype !=# "help"
    setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78

    if exists("+colorcolumn")
      setlocal colorcolumn=+1
    endif

    if has("conceal")
      setlocal conceallevel=0
    endif
  endif
enddef