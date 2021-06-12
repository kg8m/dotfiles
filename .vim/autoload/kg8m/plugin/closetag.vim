vim9script

const FILETYPES = ["eruby", "html", "javascript", "markdown", "typescript"]

def kg8m#plugin#closetag#configure(): void
  g:closetag_filetypes = join(FILETYPES, ",")
  g:closetag_shortcut  = "\\>"

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: FILETYPES,
    hook_post_source: () => s:on_post_source(),
  })
enddef

def kg8m#plugin#closetag#filetypes(): list<string>
  return FILETYPES
enddef

def s:on_post_source(): void
  timer_start(0, (_) => kg8m#events#notify_insert_mode_plugin_loaded())
enddef
