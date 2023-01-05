vim9script

import autoload "kg8m/events.vim"

export def WithNotify(mapping: string): string
  timer_start(100, (_) => events.NotifySearchStart())
  return mapping
enddef
