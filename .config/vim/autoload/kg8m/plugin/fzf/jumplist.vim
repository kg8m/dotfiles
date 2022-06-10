vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

export def Back(): void
  const info = JumplistInfo()

  if info.current_position <# 1
    kg8m#util#logger#Warn("Cannot jump.")
    return
  endif

  const candidates = JumplistToCandidates(
    reverse(info.jumplist[0 : info.current_position]),
    {
      direction:    -1,
      index_offset: [0, info.current_position + 1 - len(info.jumplist)]->max(),
    }
  )

  Run(candidates)
enddef

export def Forward(): void
  const info = JumplistInfo()

  if info.current_position >=# len(info.jumplist)
    kg8m#util#logger#Warn("Cannot jump.")
    return
  endif

  const candidates = JumplistToCandidates(info.jumplist[info.current_position : -1])

  Run(candidates)
enddef

def Run(candidates: list<string>): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  candidates,
    sink:    Handler,
    options: [
      "--no-multi",
      "--header-lines", match(candidates[0], '\v^\s*0') ==# -1 ? 0 : 1,
      "--nth", "2..",
      "--prompt", "Jumplist> ",
      "--delimiter", ":",
      "--preview", "preview {2..}",
      "--preview-window", "down:75%:wrap:nohidden:+{3}-/2",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("jumplist", options)))
enddef

def JumplistInfo(): dict<any>
  const info = getjumplist()
  return { jumplist: info[0], current_position: info[1] }
enddef

def JumplistToCandidates(jumplist: list<dict<any>>, options: dict<any> = {}): list<string>
  const direction    = get(options, "direction", 1)
  const index_offset = get(options, "index_offset", 0)
  const index_width  = len(len(jumplist) - 1) + (direction <# 0 ? 1 : 0)
  const format       = $"%{index_width}d:%s:%d:%d"

  return jumplist->mapnew((i, bufinfo) => (
    printf(format, (i + index_offset) * direction, BufnrToFilepath(bufinfo.bufnr), bufinfo.lnum, bufinfo.col)
  ))
enddef

def BufnrToFilepath(bufnr: number): string
  const filepath = bufname(bufnr)

  if empty(filepath)
    const filetype = getbufvar(bufnr, "&filetype")
    return printf("[%s]", empty(filetype) ? "No Name" : filetype)
  elseif !filereadable(filepath)
    return printf("[%s]", filepath)
  else
    return filepath
  endif
enddef

def Handler(candidate: string): void
  const index = candidate->trim()->matchstr('\v^-?\d+')->str2nr()

  if index <# 0
    feedkeys($"{index * -1}\<C-o>")
  else
    feedkeys($"{index}\<C-i>")
  endif
enddef
