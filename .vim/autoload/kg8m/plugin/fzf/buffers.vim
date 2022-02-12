vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# Sort buffers in dictionary order (fzf's `:Buffers` doesn't sort them)
export def Run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#plugin#fzf#buffers#List(),
    "sink*": function("kg8m#plugin#fzf#buffers#Handler"),
    options: kg8m#plugin#fzf#buffers#BaseOptions() + [
      "--prompt", "Buffers> ",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("buffer-files", options)))
enddef

export def List(options: dict<any> = {}): list<string>
  const sorter = get(options, "sorter") ?? funcref("DefaultSorter")

  const current = [kg8m#util#file#CurrentPath()]->filter((_, filepath) => !empty(filepath))
  const buffers = BufinfoList()->sort(sorter)->mapnew((_, bufinfo) => kg8m#util#file#FormatPath(bufinfo.name))

  return kg8m#util#list#Vital().uniq(current + buffers)
enddef

def BufinfoList(): list<dict<any>>
  const MapperCallback = (bufinfo) => empty(bufinfo.name) ? false : bufinfo
  return getbufinfo({ buflisted: true })->kg8m#util#list#FilterMap(MapperCallback)
enddef

def DefaultSorter(lhs: dict<any>, rhs: dict<any>): number
  return lhs.name <# rhs.name ? 1 : -1
enddef

# Don't use fzf.vim's default handler because it can't open non-persisted, e.g., `buftype=nofile` set, buffers.
export def Handler(lines: list<string>): void
  if empty(lines)
    return
  endif

  const key = lines[0]
  const command = empty(key) ? "edit" : g:fzf_action[key]

  for line in lines[1 : -1]
    execute printf("%s %s", command, fnameescape(line))
  endfor
enddef

export def BaseOptions(): list<any>
  return [
    "--header-lines", empty(kg8m#util#file#CurrentPath()) ? 0 : 1,
    "--preview", "preview {}",
    "--preview-window", "down:75%:wrap:nohidden",
    "--expect", g:fzf_action->keys()->join(","),
  ]
enddef
