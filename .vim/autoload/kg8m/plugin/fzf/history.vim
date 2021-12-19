vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

# Ignore some files, e.g., `.git/COMMIT_EDITMSG` (fzf's `:History` doesn't ignore them)
def kg8m#plugin#fzf#history#run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  s:candidates(),
    options: [
      "--header-lines", empty(kg8m#util#file#current_path()) ? 0 : 1,
      "--prompt", "History> ",
      "--preview", "git cat {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("history-files", options)))
enddef

# `buffers` are for files not included in `mr#mru#list()`, e.g.,
#   - renamed files by `:Rename`
#   - opened files by `vim foo bar baz`
def s:candidates(): list<string>
  const buffers  = kg8m#plugin#fzf#buffers#list({ sorter: function("s:buffers_sorter") })
  const oldfiles = s:get_oldfiles()

  return kg8m#util#list#vital().uniq(buffers + oldfiles)
enddef

def s:buffers_sorter(lhs: dict<any>, rhs: dict<any>): number
  if lhs.lastused ==# rhs.lastused
    return lhs.name <# rhs.name ? 1 : -1
  else
    return lhs.lastused <# rhs.lastused ? 1 : -1
  endif
enddef

def s:get_oldfiles(): list<string>
  const MapperCallback = (filepath) => filereadable(filepath) ? kg8m#util#file#format_path(filepath) : false
  return mr#mru#list()->kg8m#util#list#filter_map(MapperCallback)
enddef
