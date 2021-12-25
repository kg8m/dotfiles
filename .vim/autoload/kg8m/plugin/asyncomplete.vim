vim9script

def kg8m#plugin#asyncomplete#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:on_source(): void
  g:asyncomplete_auto_popup = true
  g:asyncomplete_popup_delay = 50
  g:asyncomplete_auto_completeopt = false

  # Usually disable asyncomplete.vim's logging because it makes Vim slower.
  # g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  # Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  g:asyncomplete_preprocessor = [function("kg8m#plugin#asyncomplete#preprocessor#callback")]

  augroup vimrc-plugin-asyncomplete
    autocmd!
    autocmd BufWinEnter                 * kg8m#plugin#completion#set_refresh_pattern()
    autocmd FileType                    * kg8m#plugin#completion#reset_refresh_pattern()
    autocmd User after_lsp_buffer_enabled kg8m#plugin#completion#reset_refresh_pattern()
  augroup END
enddef

def s:on_post_source(): void
  timer_start(0, (_) => kg8m#events#notify_insert_mode_plugin_loaded())
  timer_start(0, (_) => kg8m#plugin#completion#set_refresh_pattern())

  if get(b:, "asyncomplete_enable", true)
    asyncomplete#enable_for_buffer()
  endif
enddef
