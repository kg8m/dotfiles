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

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: g:kg8m#plugin#closetag#filetypes,
    hook_source:      () => OnSource(),
    hook_post_source: () => OnPostSource(),
  })
enddef

def OnSource(): void
  g:closetag_filetypes = join(g:kg8m#plugin#closetag#filetypes, ",")
  g:closetag_shortcut  = "\\>"
enddef

def OnPostSource(): void
  timer_start(0, (_) => kg8m#events#NotifyInsertModePluginLoaded())
enddef
