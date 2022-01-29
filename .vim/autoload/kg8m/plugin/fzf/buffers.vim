vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

# Sort buffers in dictionary order (fzf's `:Buffers` doesn't sort them)
def kg8m#plugin#fzf#buffers#run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#plugin#fzf#buffers#list(),
    "sink*": function("kg8m#plugin#fzf#buffers#handler"),
    options: kg8m#plugin#fzf#buffers#base_options() + [
      "--prompt", "Buffers> ",
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

# Don't use fzf.vim's default handler because it can't open non-persisted, e.g., `buftype=nofile` set, buffers.
def kg8m#plugin#fzf#buffers#handler(lines: list<string>): void
  if empty(lines)
    return
  endif

  const key = lines[0]
  const command = empty(key) ? "edit" : g:fzf_action[key]

  for line in lines[1 : -1]
    execute printf("%s %s", command, fnameescape(line))
  endfor
enddef

def kg8m#plugin#fzf#buffers#base_options(): list<any>
  return [
    "--header-lines", empty(kg8m#util#file#current_path()) ? 0 : 1,
    "--preview", "preview {}",
    "--preview-window", "down:75%:wrap:nohidden",
    "--expect", g:fzf_action->keys()->join(","),
  ]
enddef
