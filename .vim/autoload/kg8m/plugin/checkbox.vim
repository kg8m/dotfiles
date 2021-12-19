vim9script

def kg8m#plugin#checkbox#configure(): void
  augroup my_vimrc
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call kg8m#plugin#checkbox#toggle()<CR>
  augroup END

  kg8m#plugin#configure({
    lazy: true,
  })
enddef

def kg8m#plugin#checkbox#toggle(): void
  kg8m#plugin#ensure_sourced("vim-checkbox")
  checkbox#ToggleCB()
enddef
