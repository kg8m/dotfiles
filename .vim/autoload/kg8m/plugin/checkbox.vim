vim9script

def kg8m#plugin#checkbox#configure(): void
  augroup my_vimrc
    autocmd FileType markdown,moin noremap <buffer> <Leader>c :call kg8m#plugin#checkbox#toggle()<CR>
  augroup END

  kg8m#plugin#configure({
    lazy: true,
  })
enddef

# Wrap vim-checkbox's `checkbox#ToggleCB` because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
def kg8m#plugin#checkbox#toggle(): void
  if !kg8m#plugin#is_sourced("vim-checkbox")
    kg8m#plugin#source("vim-checkbox")
  endif

  checkbox#ToggleCB()
enddef
