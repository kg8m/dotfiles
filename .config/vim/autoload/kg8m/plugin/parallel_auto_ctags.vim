vim9script

import autoload "kg8m/util.vim"
import autoload "kg8m/util/logger.vim"

const SECONDS_AS_OLDFILE = 5 * 60

export def OnSource(): void
  g:parallel_auto_ctags#entry_points = {
    pwd: {
      path:    ".",

      # Use my `MyJavaScript` instead of built-in `JavaScript` because it is broken.
      # cf. https://github.com/universal-ctags/ctags/issues/900
      options: ["--languages=Go,MyJavaScript,Make,Ruby,Sh,TypeScript,Vim,Yaml"],

      events:  ["VimEnter", "BufWritePost"],
      silent:  false,
    },
  }

  if util.OnRailsDir()
    const rubygems_path = util.RubygemsPath()
    &tags ..= $",{rubygems_path}/../tags"

    g:parallel_auto_ctags#entry_points.gems = {
      path:    $"{rubygems_path}/..",
      options: ["--exclude=test", "--exclude=spec", "--languages=Ruby"],
      events:  ["VimEnter"],
      silent:  false,
    }
  endif
enddef

export def OnPostSource(): void
  CleanUpOldLockfiles()
  parallel_auto_ctags#create_all()
  timer_start(SECONDS_AS_OLDFILE * 1000, (_) => CleanUpOldLockfiles(), { repeat: -1 })
enddef

def CleanUpOldLockfiles(): void
  for name in keys(g:parallel_auto_ctags#entry_points)
    const config = g:parallel_auto_ctags#entry_points[name]
    const lockpath = $"{config.path}/tags.lock"

    if !filereadable(lockpath)
      continue
    endif

    if localtime() - getftime(lockpath) ># SECONDS_AS_OLDFILE
      delete(lockpath)
      logger.Info($"[ctags] The lock file `{lockpath}` has been deleted because too old.")
    endif
  endfor
enddef
