vim9script

def kg8m#plugin#undotree#configure(): void  # {{{
  nnoremap <Leader>u :UndotreeToggle<CR>

  g:undotree_WindowLayout = 2
  g:undotree_SplitWidth = 50
  g:undotree_DiffpanelHeight = 30
  g:undotree_SetFocusWhenToggle = v:true

  kg8m#plugin#configure({
    lazy:   v:true,
    on_cmd: "UndotreeToggle",
  })
enddef  # }}}
