function kg8m#util#dim_inactive_windows#setup() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd WinEnter        * call s:apply()
    autocmd SessionLoadPost * call timer_start(0, { -> s:apply() })
    autocmd VimResized      * call s:apply(#{ force: v:true })
  augroup END  " }}}
endfunction  " }}}

function kg8m#util#dim_inactive_windows#reset() abort  " {{{
  bufdo call s:reset_buffer()
endfunction  " }}}

function s:apply(options = {}) abort  " {{{
  let current_winnr = winnr()
  let last_winnr    = winnr("$")
  let colorcolumns  = range(1, &columns)->join(",")

  if has_key(b:, "original_colorcolumn")
    call s:reset_buffer()
  else
    let b:original_colorcolumn = &colorcolumn
  endif

  for winnr in range(1, last_winnr)
    if winnr !=# current_winnr
      if getbufvar(winbufnr(winnr), "original_colorcolumn", v:null) ==# v:null
        call setbufvar(winbufnr(winnr), "original_colorcolumn", getwinvar(winnr, "&colorcolumn"))
      endif

      if getwinvar(winnr, "original_colorcolumn", v:null) ==# v:null
        call setwinvar(winnr, "&colorcolumn", colorcolumns)
      else
        if get(a:options, "force", v:false)
          call setwinvar(winnr, "&colorcolumn", colorcolumns)
        endif
      endif
    endif
  endfor
endfunction  " }}}

function s:reset_buffer() abort  " {{{
  let &l:colorcolumn = b:original_colorcolumn
endfunction  " }}}
