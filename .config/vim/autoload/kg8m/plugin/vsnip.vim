vim9script

export def OnPostSource(): void
  timer_start(0, (_) => kg8m#events#NotifyInsertModePluginLoaded())
enddef
