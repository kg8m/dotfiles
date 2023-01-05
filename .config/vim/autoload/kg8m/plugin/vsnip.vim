vim9script

import autoload "kg8m/events.vim"

export def OnPostSource(): void
  timer_start(0, (_) => events.NotifyInsertModePluginLoaded())
enddef
