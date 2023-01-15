vim9script

import autoload "kg8m/configure/filetypes/javascript.vim" as jsConfig
import autoload "kg8m/events.vim"

export const FILETYPES = [
  "eruby",
  "html",
  "markdown",
] + jsConfig.JS_FILETYPES + jsConfig.TS_FILETYPES

export def OnSource(): void
  g:closetag_filetypes = join(FILETYPES, ",")
  g:closetag_shortcut  = "\\>"
enddef

export def OnPostSource(): void
  timer_start(0, (_) => events.NotifyInsertModePluginLoaded())
enddef
