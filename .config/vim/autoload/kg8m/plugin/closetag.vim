vim9script

import autoload "kg8m/events.vim"

export const FILETYPES = [
  "eruby",
  "html",
  "javascript",
  "javascriptreact",
  "markdown",
  "typescript",
  "typescriptreact",
]

export def OnSource(): void
  g:closetag_filetypes = join(FILETYPES, ",")
  g:closetag_shortcut  = "\\>"
enddef

export def OnPostSource(): void
  timer_start(0, (_) => events.NotifyInsertModePluginLoaded())
enddef
