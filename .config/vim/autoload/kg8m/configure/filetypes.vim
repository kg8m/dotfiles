vim9script

import autoload "kg8m/configure/filetypes/c.vim"
import autoload "kg8m/configure/filetypes/go.vim"
import autoload "kg8m/configure/filetypes/javascript.vim"
import autoload "kg8m/configure/filetypes/markdown.vim"

export def Run(): void
  c.Run()
  go.Run()
  javascript.Run()
  markdown.Run()
enddef
