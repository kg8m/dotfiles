vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

# Sort buffers in dictionary order (fzf's `:Buffers` doesn't sort them)
def kg8m#plugin#fzf#buffers#run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#plugin#fzf#buffers#list(),
    options: [
      "--header-lines", empty(kg8m#util#file#current_path()) ? 0 : 1,
      "--prompt", "Buffers> ",
      "--preview", "git cat {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("buffer-files", options)))
enddef

def kg8m#plugin#fzf#buffers#list(options: dict<any> = {}): list<string>
  const sorter = get(options, "sorter") ?? function("s:default_sorter")

  const current = [kg8m#util#file#current_path()]->filter((_, filepath) => !empty(filepath))
  const buffers = s:bufinfo_list()->sort(sorter)->mapnew((_, bufinfo) => kg8m#util#file#format_path(bufinfo.name))

  return kg8m#util#list#vital().uniq(current + buffers)
enddef

def s:bufinfo_list(): list<dict<any>>
  const MapperCallback = (bufinfo) => empty(bufinfo.name) ? false : bufinfo
  return getbufinfo({ buflisted: true })->kg8m#util#list#filter_map(MapperCallback)
enddef

def s:default_sorter(lhs: dict<any>, rhs: dict<any>): number
  return lhs.name <# rhs.name ? 1 : -1
enddef
