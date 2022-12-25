vim9script

export def WithNotify(mapping: string): string
  timer_start(100, (_) => kg8m#events#NotifySearchStart())
  return mapping
enddef
