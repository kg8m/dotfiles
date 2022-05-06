vim9script

var timer = -1

export def Setup(): void
  augroup vimrc-util-dim_inactive_windows
    autocmd!
    autocmd WinEnter        * Trigger()
    autocmd SessionLoadPost * Trigger()
    autocmd VimResized      * Trigger({ force: true })
  augroup END
enddef

export def Reset()
  bufdo if has_key(b:, "original_colorcolumn") | ResetBuffer() | endif
enddef

def Trigger(options = {}): void
  timer_stop(timer)
  timer = timer_start(50, (_) => Apply(options))
enddef

def Apply(options = {}): void
  const current_winnr = winnr()
  const last_winnr    = winnr("$")
  const colorcolumns  = range(1, &columns)->join(",")

  if has_key(b:, "original_colorcolumn")
    ResetBuffer()
  else
    b:original_colorcolumn = &colorcolumn
  endif

  for winnr in range(1, last_winnr)
    # Skip diff windows because colorcolumn hides diff colors.
    if getwinvar(winnr, "&diff")
      continue
    endif

    if winnr !=# current_winnr
      if getbufvar(winbufnr(winnr), "original_colorcolumn", v:null) ==# v:null
        setbufvar(winbufnr(winnr), "original_colorcolumn", getwinvar(winnr, "&colorcolumn"))
      endif

      if getwinvar(winnr, "original_colorcolumn", v:null) ==# v:null
        setwinvar(winnr, "&colorcolumn", colorcolumns)
      else
        if get(options, "force", false)
          setwinvar(winnr, "&colorcolumn", colorcolumns)
        endif
      endif
    endif
  endfor
enddef

def ResetBuffer(): void
  &l:colorcolumn = b:original_colorcolumn
enddef
