vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# May there be a Vim9 script's bug that `FuncUndefined` event is not triggered?
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Ignore some files, e.g., `.git/COMMIT_EDITMSG` (Fzf's `:History` doesn't ignore them)
def kg8m#plugin#fzf#history#run(): void  # {{{
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  s:candidates(),
    options: [
      "--header-lines", empty(kg8m#plugin#fzf#current_filepath()) ? 0 : 1,
      "--prompt", "History> ",
      "--preview", "git cat {}",
      "--preview-window", "right:50%:wrap:nohidden",
    ],
  }

  fzf#run(fzf#wrap("history-files", options))
enddef  # }}}

# `buffers` are for files not included in `mr#mru#list()`, e.g.,
#   - renamed files by `:Rename`
#   - opened files by `vim foo bar baz`
def s:candidates(): list<string>  # {{{
  const current  = [kg8m#plugin#fzf#current_filepath()]->filter("!empty(v:val)")
  const buffers  = s:get_buffers()
  const oldfiles = s:get_oldfiles()

  return kg8m#util#list_module().uniq(current + buffers + oldfiles)
enddef  # }}}

def s:get_buffers(): list<string>  # {{{
  return getbufinfo()
    ->sort("s:buffers_sorter")
    ->filter("!empty(v:val.name)")
    ->map("v:val.name->fnamemodify(kg8m#plugin#fzf#filepath_format())")
enddef  # }}}

def s:buffers_sorter(lhs: dict<any>, rhs: dict<any>): number  # {{{
  if lhs.lastused ==# rhs.lastused
    return lhs.name <# rhs.name ? 1 : -1
  else
    return lhs.lastused <# rhs.lastused ? 1 : -1
  endif
enddef  # }}}

def s:get_oldfiles(): list<string>  # {{{
  final filepaths = mr#mru#list()->copy()->filter("v:val->filereadable()")
  return filepaths->map("v:val->fnamemodify(kg8m#plugin#fzf#filepath_format())")
enddef  # }}}
