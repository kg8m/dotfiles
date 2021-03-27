vim9script

def kg8m#plugin#dwm#configure(): void
  nnoremap <C-w>n       :call DWM_New()<CR>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<CR>

  kg8m#plugin#configure({
    lazy:    true,
    on_cmd:  ["DWMOpen"],
    on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:open(filepath: string): void
  if bufexists(filepath)
    const winnr = bufwinnr(filepath)

    if winnr ==# -1
      DWM_Stack(1)
      split
      execute "edit " .. filepath
      DWM_AutoEnter()
    else
      execute printf(":%dwincmd w", winnr)
      DWM_AutoEnter()
    endif
  else
    if bufname("%") !=# ""
      DWM_New()
    endif

    execute "edit " .. filepath
  endif
enddef

def s:on_source(): void
  g:dwm_map_keys = false

  # For fzf.vim
  command! -nargs=1 -complete=file DWMOpen s:open(<q-args>)
enddef

def s:on_post_source(): void
  # Disable DWM's default behavior on buffer loaded
  augroup dwm
    autocmd!
  augroup END
enddef
