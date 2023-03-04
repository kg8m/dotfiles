vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/util/logger.vim"

export def Run(options: dict<any> = {}): void
  timer_start(   1, (_) => Main(options) )
  timer_start( 200, (_) => RemoveDisused())
  timer_start(1000, (_) => ShowLogs())
enddef

def Main(options: dict<any> = {}): void
  # Re-register disabled plugins before update because dein.vim doesn't make helptags for them
  plugin.EnableDisabledPlugins()

  if get(options, "bulk", true)
    const force_update = true
    dein#check_update(force_update)
  else
    dein#update()
  endif
enddef

def RemoveDisused(): void
  for dirpath in dein#check_clean()
    logger.Warn($"Remove {dirpath}")
    delete(dirpath, "rf")
  endfor
enddef

export def ShowLogs(): void
  denops#plugin#wait_async("kg8m", () => {
    denops#notify("kg8m", "dein:update:logs:show", [])
  })
enddef

plugin.EnsureSourced("denops.vim")
