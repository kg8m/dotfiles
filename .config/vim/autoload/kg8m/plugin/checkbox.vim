vim9script

import autoload "kg8m/plugin.vim"

export def Run(): void
  checkbox#ToggleCB()
enddef

plugin.EnsureSourced("vim-checkbox")
