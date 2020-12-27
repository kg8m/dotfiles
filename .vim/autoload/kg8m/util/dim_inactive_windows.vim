vim9script

def kg8m#util#dim_inactive_windows#setup()  # {{{
  augroup my_vimrc  # {{{
    autocmd WinEnter        * s:apply()
    autocmd SessionLoadPost * timer_start(0, { -> s:apply() })
    autocmd VimResized      * s:apply({ force: true })
  augroup END  # }}}
enddef  # }}}

def kg8m#util#dim_inactive_windows#reset()  # {{{
  bufdo if has_key(b:, "original_colorcolumn") | s:reset_buffer() | endif
enddef  # }}}

def s:apply(options = {})  # {{{
  const current_winnr = winnr()
  const last_winnr    = winnr("$")
  const colorcolumns  = range(1, &columns)->join(",")

  if has_key(b:, "original_colorcolumn")
    s:reset_buffer()
  else
    b:original_colorcolumn = &colorcolumn
  endif

  for winnr in range(1, last_winnr)
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
enddef  # }}}

def s:reset_buffer()  # {{{
  &l:colorcolumn = b:original_colorcolumn
enddef  # }}}
