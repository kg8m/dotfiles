vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# Ignore some files, e.g., `.git/COMMIT_EDITMSG` (fzf's `:History` doesn't ignore them)
export def Run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  Candidates(),
    "sink*": function("kg8m#plugin#fzf#buffers#Handler"),
    options: kg8m#plugin#fzf#buffers#BaseOptions() + [
      "--prompt", "History> ",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("history-files", options)))
enddef

# `buffers` are for files not included in `mr#mru#list()`, e.g.,
#   - renamed files by `:Rename`
#   - opened files by `vim foo bar baz`
def Candidates(): list<string>
  const buffers  = kg8m#plugin#fzf#buffers#List({ sorter: funcref("BuffersSorter") })
  const oldfiles = Oldfiles()

  return kg8m#util#list#Union(buffers, oldfiles)
enddef

def BuffersSorter(lhs: dict<any>, rhs: dict<any>): number
  if lhs.lastused ==# rhs.lastused
    return lhs.name <# rhs.name ? 1 : -1
  else
    return lhs.lastused <# rhs.lastused ? 1 : -1
  endif
enddef

def Oldfiles(): list<string>
  const MapperCallback = (filepath) => filereadable(filepath) ? kg8m#util#file#NormalizePath(filepath) : false
  return mr#mru#list()->kg8m#util#list#FilterMap(MapperCallback)
enddef
