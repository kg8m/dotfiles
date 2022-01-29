vim9script

g:kg8m#plugin#closetag#filetypes = [
  "eruby",
  "html",
  "javascript",
  "javascriptreact",
  "markdown",
  "typescript",
  "typescriptreact",
]

def kg8m#plugin#closetag#configure(): void
  g:closetag_filetypes = join(g:kg8m#plugin#closetag#filetypes, ",")
  g:closetag_shortcut  = "\\>"

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: g:kg8m#plugin#closetag#filetypes,
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:on_post_source(): void
  timer_start(0, (_) => kg8m#events#notify_insert_mode_plugin_loaded())
enddef
