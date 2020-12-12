function kg8m#plugin#undotree#configure() abort  " {{{
  nnoremap <Leader>u :UndotreeToggle<Cr>

  let g:undotree_WindowLayout = 2
  let g:undotree_SplitWidth = 50
  let g:undotree_DiffpanelHeight = 30
  let g:undotree_SetFocusWhenToggle = v:true

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: "UndotreeToggle",
  \ })
endfunction  " }}}
