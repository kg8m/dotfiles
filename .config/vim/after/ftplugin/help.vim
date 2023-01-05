vim9script

import autoload "kg8m/util.vim"
import autoload "kg8m/util/help.vim"

if util.IsGitCommit()
  # Restore correct filetype that was set by modelines.
  set filetype=gitcommit
else
  timer_start(200, (_) => help.SetupWriting())
endif
