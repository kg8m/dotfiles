vim9script

augroup vimrc-events
  autocmd!
  autocmd User search_start              ++once silent
  autocmd User clear_search_highlight    ++once silent
  autocmd User insert_mode_plugin_loaded ++once silent
  autocmd User after_lsp_buffer_enabled  ++once silent
augroup END

export def NotifySearchStart(): void
  doautocmd <nomodeline> User search_start
enddef

export def NotifyClearSearchHighlight(): void
  doautocmd <nomodeline> User clear_search_highlight
enddef

export def NotifyInsertModePluginLoaded(): void
  doautocmd <nomodeline> User insert_mode_plugin_loaded
enddef

export def NotifyAfterLspBufferEnabled(): void
  doautocmd <nomodeline> User after_lsp_buffer_enabled
enddef
