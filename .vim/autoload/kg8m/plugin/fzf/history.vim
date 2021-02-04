vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Ignore some files, e.g., `.git/COMMIT_EDITMSG` (Fzf's `:History` doesn't ignore them)
def kg8m#plugin#fzf#history#run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  s:candidates(),
    options: [
      "--header-lines", empty(kg8m#util#file#current_path()) ? 0 : 1,
      "--prompt", "History> ",
      "--preview", "git cat {}",
      "--preview-window", "right:50%:wrap:nohidden",
    ],
  }

  fzf#run(fzf#wrap("history-files", options))
enddef

# `buffers` are for files not included in `mr#mru#list()`, e.g.,
#   - renamed files by `:Rename`
#   - opened files by `vim foo bar baz`
def s:candidates(): list<string>
  const current  = [kg8m#util#file#current_path()]->filter((_, filepath) => !empty(filepath))
  const buffers  = s:get_buffers()
  const oldfiles = s:get_oldfiles()

  return kg8m#util#list#vital().uniq(current + buffers + oldfiles)
enddef

def s:get_buffers(): list<string>
  const MapperCallback = (bufinfo) => empty(bufinfo.name) ? false : kg8m#util#file#format_path(bufinfo.name)
  return getbufinfo()->sort("s:buffers_sorter")->kg8m#util#list#filter_map(MapperCallback)
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
