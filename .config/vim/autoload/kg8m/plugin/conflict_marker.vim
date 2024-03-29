vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/util/logger.vim"

final cache = {
  active: false,
  notified: false,
}

export def OnSource(): void
  g:conflict_marker_enable_mappings = false
enddef

export def SetupBuffer(): void
  # NOTE: `&diff` is always falsy before `VimEnter`.
  if &diff
    nmap <buffer> <Leader>c <Plug>(conflict-marker-next-hunk)
    cache.active = true

    if !cache.notified && plugin.AreAllOnStartPluginsSourced()
      NotifyActivated()
    endif
  endif
enddef

export def NotifyActivated(): void
  if cache.active
    logger.Info("Press `<Leader>c` to move to next conflict hunk.")
    cache.notified = true
  endif
enddef
