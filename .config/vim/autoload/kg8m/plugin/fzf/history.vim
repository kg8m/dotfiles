vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"
import autoload "kg8m/plugin/fzf/buffers.vim" as fzfBuffers
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/list.vim" as listUtil

plugin.EnsureSourced("fzf.vim")

# Ignore some files, e.g., `.git/COMMIT_EDITMSG` (fzf's `:History` doesn't ignore them)
export def Run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  Candidates(),
    "sink*": fzfBuffers.Handler,
    options: fzfBuffers.BaseOptions() + [
      "--prompt", "History> ",
    ],
  }

  fzf.Run(() => fzf#run(fzf#wrap("history-files", options)))
enddef

# `buffers` are for files not included in `mr#mru#list()`, e.g.,
#   - renamed files by `:Rename`
#   - opened files by `vim foo bar baz`
def Candidates(): list<string>
  const buffers  = fzfBuffers.List({ sorter: BuffersSorter })
  const oldfiles = Oldfiles()

  return listUtil.Union(buffers, oldfiles, fzfBuffers.RemoveExtraInfo)
enddef

def BuffersSorter(lhs: dict<any>, rhs: dict<any>): number
  if lhs.lastused ==# rhs.lastused
    return lhs.name <# rhs.name ? 1 : -1
  else
    return lhs.lastused <# rhs.lastused ? 1 : -1
  endif
enddef

def Oldfiles(): list<string>
  const MapperCallback = (filepath) => filereadable(filepath) ? fileUtil.NormalizePath(filepath) : false
  return mr#mru#list()->listUtil.FilterMap(MapperCallback)
enddef
