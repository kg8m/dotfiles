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

export def OnSource(): void
  g:closetag_filetypes = join(g:kg8m#plugin#closetag#filetypes, ",")
  g:closetag_shortcut  = "\\>"
enddef

export def OnPostSource(): void
  timer_start(0, (_) => kg8m#events#NotifyInsertModePluginLoaded())
enddef
