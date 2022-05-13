vim9script

export def Configure(): void
  nnoremap <C-w>n       :call DWM_New()<CR>
  nnoremap <C-w><Space> :call DWM_AutoEnter()<CR>

  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  ["DWMOpen"],
    on_func: ["DWM_New", "DWM_AutoEnter", "DWM_Stack"],
    hook_source:      () => OnSource(),
    hook_post_source: () => OnPostSource(),
  })
enddef

def Open(filepath: string): void
  if bufexists(filepath)
    const winnr = bufwinnr(filepath)

    if winnr ==# -1
      g:DWM_Stack(1)
      split
      execute "edit" fnameescape(filepath)
      g:DWM_AutoEnter()
    else
      execute $":{winnr}wincmd w"
      g:DWM_AutoEnter()
    endif
  else
    if bufname("%") !=# ""
      g:DWM_New()
    endif

    execute "edit" fnameescape(filepath)
  endif
enddef

def OnSource(): void
  g:dwm_map_keys = false

  # For fzf.vim
  command! -nargs=1 -complete=file DWMOpen Open(<q-args>)
enddef

def OnPostSource(): void
  # Disable DWM's default behavior on buffer loaded
  augroup dwm
    autocmd!
  augroup END
enddef
