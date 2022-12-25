vim9script

export def OnSource(): void
  g:asyncomplete_auto_popup = true
  g:asyncomplete_popup_delay = 50
  g:asyncomplete_auto_completeopt = false

  # Usually disable asyncomplete.vim's logging because it makes Vim slower.
  # g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  # Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  g:asyncomplete_preprocessor = [function("kg8m#plugin#asyncomplete#preprocessor#Callback")]

  augroup vimrc-plugin-asyncomplete
    autocmd!
    autocmd BufWinEnter                 * kg8m#plugin#completion#SetRefreshPattern()
    autocmd FileType                    * kg8m#plugin#completion#ResetRefreshPattern()
    autocmd User after_lsp_buffer_enabled kg8m#plugin#completion#ResetRefreshPattern()
  augroup END
enddef

export def OnPostSource(): void
  timer_start(0, (_) => kg8m#events#NotifyInsertModePluginLoaded())
  timer_start(0, (_) => kg8m#plugin#completion#SetRefreshPattern())

  if get(b:, "asyncomplete_enable", true)
    asyncomplete#enable_for_buffer()
  endif
enddef
