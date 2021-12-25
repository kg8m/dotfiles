vim9script

augroup vimrc-events
  autocmd!
  autocmd User search_start              silent
  autocmd User clear_search_highlight    silent
  autocmd User insert_mode_plugin_loaded silent
  autocmd User after_lsp_buffer_enabled  silent
augroup END

def kg8m#events#notify_search_start(): void
  doautocmd <nomodeline> User search_start
enddef

def kg8m#events#notify_clear_search_highlight(): void
  doautocmd <nomodeline> User clear_search_highlight
enddef

def kg8m#events#notify_insert_mode_plugin_loaded(): void
  doautocmd <nomodeline> User insert_mode_plugin_loaded
enddef

def kg8m#events#notify_after_lsp_buffer_enabled(): void
  doautocmd <nomodeline> User after_lsp_buffer_enabled
enddef
