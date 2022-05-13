vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

const EXTRA_INFO_SEPARATOR = repeat(" ", 10)
const EXTRA_INFO_PATTERN = $'{EXTRA_INFO_SEPARATOR}.*$'

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

  const current = CurrentList()->map((_, filepath) => FormatBufname(filepath, &modified))
  const buffers = BufinfoList()->sort(sorter)->mapnew((_, bufinfo) => FormatBufname(bufinfo.name, bufinfo.changed))

  return kg8m#util#list#Union(current, buffers, funcref("RemoveExtraInfo"))
enddef

def CurrentList(): list<string>
  const current = kg8m#util#file#CurrentPath()
  return empty(current) ? [] : [current]
enddef

def BufinfoList(): list<dict<any>>
  const MapperCallback = (bufinfo) => empty(bufinfo.name) ? false : bufinfo
  return getbufinfo({ buflisted: true })->kg8m#util#list#FilterMap(MapperCallback)
enddef

def FormatBufname(bufname: string, modified: bool): string
  const normalized_bufname = kg8m#util#file#NormalizePath(bufname)
  const modified_symbol    = modified ? kg8m#util#string#colors#Yellow("[+]") : ""

  return normalized_bufname .. EXTRA_INFO_SEPARATOR .. modified_symbol
enddef

export def RemoveExtraInfo(bufname: string): string
  return substitute(bufname, EXTRA_INFO_PATTERN, "", "")
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
    const filepath = RemoveExtraInfo(line)
    execute command fnameescape(filepath)
  endfor
enddef

export def BaseOptions(): list<any>
  return [
    "--header-lines", empty(kg8m#util#file#CurrentPath()) ? 0 : 1,
    "--preview", printf("preview \"$(echo {} | sd '%s' '')\"", EXTRA_INFO_PATTERN),
    "--preview-window", "down:75%:wrap:nohidden",
    "--expect", g:fzf_action->keys()->join(","),
  ]
enddef
