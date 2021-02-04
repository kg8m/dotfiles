vim9script

def kg8m#plugin#asyncomplete#configure(): void
  kg8m#plugin#configure({
    lazy: true,
    on_i: true,
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:on_source(): void
  g:asyncomplete_auto_popup = true
  g:asyncomplete_popup_delay = 50
  g:asyncomplete_auto_completeopt = false
  g:asyncomplete_log_file = expand("~/tmp/vim-asyncomplete.log")

  # Hide messages like "Pattern not found" or "Match 1 of <N>"
  set shortmess+=c

  g:asyncomplete_preprocessor = [function("kg8m#plugin#asyncomplete#preprocessor#callback")]

  augroup my_vimrc
    autocmd BufWinEnter,FileType * kg8m#plugin#completion#set_refresh_pattern()
  augroup END
enddef

def s:on_post_source(): void
  timer_start(0, () => kg8m#plugin#completion#define_refresh_mappings())

  if get(b:, "asyncomplete_enable", true)
    asyncomplete#enable_for_buffer()
  endif
enddef
