vim9script

import autoload "kg8m/plugin.vim"

export def Run(): void
  plugin.EnsureSourced("vim-checkbox")
  checkbox#ToggleCB()
enddef
