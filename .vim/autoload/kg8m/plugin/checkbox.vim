vim9script

def kg8m#plugin#checkbox#configure(): void
  augroup my_vimrc
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call <SID>run()<CR>
  augroup END

  kg8m#plugin#configure({
    lazy: true,
  })
enddef

def s:run(): void
  kg8m#plugin#ensure_sourced("vim-checkbox")
  checkbox#ToggleCB()
enddef
