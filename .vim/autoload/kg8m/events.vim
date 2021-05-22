vim9script

augroup my_vimrc
  autocmd User search_start              silent
  autocmd User clear_search_highlight    silent
augroup END

def kg8m#events#notify_search_start(): void
  doautocmd <nomodeline> User search_start
enddef

def kg8m#events#notify_clear_search_highlight(): void
  doautocmd <nomodeline> User clear_search_highlight
enddef
