vim9script

const FORMATEXPR = "jpfmt#formatexpr()"

export def OnSource(): void
  SetFormatexpr()

  g:JpFormatCursorMovedI = false
  g:JpAutoJoin = false
  g:JpAutoFormat = false

  augroup vimrc-plugin-jpformat
    autocmd!

    # Overwrite default/plugins’ `formatexpr` especially configured when multiple files are opened same time
    autocmd BufEnter * timer_start(200, (_) => SetFormatexpr())
  augroup END
enddef

def SetFormatexpr(): void
  if &l:formatexpr !=# FORMATEXPR
    # Replace built-in `jq` operator
    &l:formatexpr = FORMATEXPR
  endif
enddef
