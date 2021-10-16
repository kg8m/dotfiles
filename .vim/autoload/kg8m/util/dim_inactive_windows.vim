vim9script

var s:timer = -1

def kg8m#util#dim_inactive_windows#setup(): void
  augroup my_vimrc
    autocmd WinEnter        * s:trigger()
    autocmd SessionLoadPost * s:trigger()
    autocmd VimResized      * s:trigger({ force: true })
  augroup END
enddef

def kg8m#util#dim_inactive_windows#reset()
  bufdo if has_key(b:, "original_colorcolumn") | s:reset_buffer() | endif
enddef

def s:trigger(options = {}): void
  timer_stop(s:timer)
  s:timer = timer_start(50, (_) => s:apply(options))
enddef

def s:apply(options = {}): void
  const current_winnr = winnr()
  const last_winnr    = winnr("$")
  const colorcolumns  = range(1, &columns)->join(",")

  if has_key(b:, "original_colorcolumn")
    s:reset_buffer()
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

def s:reset_buffer(): void
  &l:colorcolumn = b:original_colorcolumn
enddef
