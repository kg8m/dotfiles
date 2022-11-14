vim9script

if kg8m#util#IsGitCommit()
  # Restore correct filetype that was set by modelines.
  set filetype=gitcommit
else
  timer_start(200, (_) => kg8m#util#help#SetupWriting())
endif
