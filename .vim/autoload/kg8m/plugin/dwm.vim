function kg8m#plugin#dwm#configure() abort  " {{{
  nnoremap <C-w>n       :call DWM_New()<Cr>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<Cr>

  let g:dwm_map_keys = v:false

  " For fzf.vim
  command! -nargs=1 -complete=file DWMOpen call s:open(<q-args>)

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

function s:open(filepath) abort  " {{{
  if bufexists(a:filepath)
    let winnr = bufwinnr(a:filepath)

    if winnr ==# -1
      call DWM_Stack(1)
      split
      execute "edit "..a:filepath
      call DWM_AutoEnter()
    else
      execute winnr.."wincmd w"
      call DWM_AutoEnter()
    endif
  else
    if bufname("%") !=# ""
      call DWM_New()
    endif

    execute "edit "..a:filepath
  endif
endfunction  " }}}

function s:on_post_source() abort  " {{{
  " Disable DWM's default behavior on buffer loaded
  augroup dwm
    autocmd!
  augroup END
endfunction  " }}}
