function kg8m#util#dim_inactive_windows#setup() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd WinEnter        * call s:apply()
    autocmd SessionLoadPost * call timer_start(0, { -> s:apply() })
    autocmd VimResized      * call s:apply(#{ force: v:true })
  augroup END  " }}}
endfunction  " }}}

function s:apply(options = {}) abort  " {{{
  let current_winnr = winnr()
  let last_winnr    = winnr("$")
  let colorcolumns  = range(1, &columns)->join(",")

  if has_key(b:, "original_colorcolumn")
    let &l:colorcolumn = b:original_colorcolumn
    unlet b:original_colorcolumn

    if has_key(w:, "original_colorcolumn")
      unlet w:original_colorcolumn
    endif
  else
    if has_key(w:, "original_colorcolumn")
      let &l:colorcolumn = w:original_colorcolumn
      unlet w:original_colorcolumn
    endif
  endif

  for winnr in range(1, last_winnr)
    if winnr !=# current_winnr
      if getwinvar(winnr, "original_colorcolumn", v:null) ==# v:null
        let original_colorcolumn = getwinvar(winnr, "&colorcolumn")

        call setbufvar(winbufnr(winnr), "original_colorcolumn", original_colorcolumn)
        call setwinvar(winnr, "original_colorcolumn", original_colorcolumn)
        call setwinvar(winnr, "&colorcolumn", colorcolumns)
      else
        if get(a:options, "force", v:false)
          call setwinvar(winnr, "&colorcolumn", colorcolumns)
        endif
      endif
    endif
  endfor
endfunction  " }}}