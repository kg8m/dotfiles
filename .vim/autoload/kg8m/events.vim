vim9script

augroup my_vimrc
  autocmd User search_start silent
augroup END

def kg8m#events#notify_search_start(): void
  doautocmd <nomodeline> User search_start
enddef
