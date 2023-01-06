vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/string/colors.vim"

const EXTRA_INFO_SEPARATOR = repeat(" ", 10)
const EXTRA_INFO_PATTERN = $'{EXTRA_INFO_SEPARATOR}.*$'

# Sort buffers in dictionary order (fzf's `:Buffers` doesn't sort them)
export def Run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  List(),
    "sink*": Handler,
    options: BaseOptions() + [
      "--prompt", "Buffers> ",
    ],
  }

  fzf.Run(() => fzf#run(fzf#wrap("buffer-files", options)))
enddef

export def List(options: dict<any> = {}): list<string>
  const Sorter = get(options, "sorter", NameSorter)

  const current = CurrentList()->map((_, filepath) => FormatBufname(filepath, &modified))
  const buffers = BufinfoList()->sort(Sorter)->mapnew((_, bufinfo) => FormatBufname(bufinfo.name, bufinfo.changed))

  return listUtil.Union(current, buffers, RemoveExtraInfo)
enddef

def CurrentList(): list<string>
  const current = fileUtil.CurrentPath()
  return empty(current) ? [] : [current]
enddef

def BufinfoList(): list<dict<any>>
  const MapperCallback = (bufinfo) => empty(bufinfo.name) ? false : bufinfo
  return getbufinfo({ buflisted: true })->listUtil.FilterMap(MapperCallback)
enddef

def FormatBufname(bufname: string, modified: bool): string
  const normalized_bufname = fileUtil.NormalizePath(bufname)
  const modified_symbol    = modified ? colors.Yellow("[+]") : ""

  return normalized_bufname .. EXTRA_INFO_SEPARATOR .. modified_symbol
enddef

export def RemoveExtraInfo(bufname: string): string
  return substitute(bufname, EXTRA_INFO_PATTERN, "", "")
enddef

def NameSorter(lhs: dict<any>, rhs: dict<any>): number
  return lhs.name <# rhs.name ? -1 : 1
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
    "--header-lines", empty(fileUtil.CurrentPath()) ? 0 : 1,
    "--preview", printf("preview \"$(echo {} | sd '%s' '')\"", EXTRA_INFO_PATTERN),
    "--preview-window", "down:75%:wrap:nohidden",
    "--expect", g:fzf_action->keys()->join(","),
  ]
enddef

plugin.EnsureSourced("fzf.vim")
