vim9script

const FORMATEXPR = "jpfmt#formatexpr()"

def kg8m#plugin#jpformat#configure(): void
  kg8m#plugin#configure({
    lazy:   true,
    on_map: { x: "gq" },
    hook_source: () => s:on_source(),
  })
enddef

def s:set_formatexpr(): void
  if &l:formatexpr !=# FORMATEXPR
    # Replace built-in `jq` operator
    &l:formatexpr = FORMATEXPR
  endif
enddef

def s:on_source(): void
  s:set_formatexpr()

  g:JpFormatCursorMovedI = false
  g:JpAutoJoin = false
  g:JpAutoFormat = false

  augroup vimrc-plugin-jpformat
    autocmd!

    # Overwrite default/plugins' `formatexpr` especially configured when multiple files are opened same time
    autocmd BufEnter * timer_start(200, (_) => s:set_formatexpr())
  augroup END
enddef
