vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

def kg8m#plugin#fzf#jumplist#back(): void
  const info = s:jumplist_info()

  if info.current_position <# 1
    kg8m#util#logger#warn("Cannot jump.")
    return
  endif

  const candidates = s:jumplist_to_candidates(
    reverse(info.jumplist[0 : info.current_position]),
    {
      direction:    -1,
      index_offset: [0, info.current_position + 1 - len(info.jumplist)]->max(),
    }
  )

  s:run(candidates)
enddef

def kg8m#plugin#fzf#jumplist#forward(): void
  const info = s:jumplist_info()

  if info.current_position >=# len(info.jumplist)
    kg8m#util#logger#warn("Cannot jump.")
    return
  endif

  const candidates = s:jumplist_to_candidates(info.jumplist[info.current_position : -1])

  s:run(candidates)
enddef

def s:run(candidates: list<string>): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  candidates,
    sink:    function("s:handler"),
    options: [
      "--no-multi",
      "--header-lines", match(candidates[0], '\v^\s*0') ==# -1 ? 0 : 1,
      "--nth", "2..",
      "--prompt", "Jumplist> ",
      "--delimiter", ":",
      "--preview", kg8m#plugin#get_info("fzf.vim").path .. "/bin/preview.sh {2..}",
      "--preview-window", "down:75%:wrap:nohidden:+{3}-/2",
    ],
  }

  fzf#run(fzf#wrap("jumplist", options))
enddef

def s:jumplist_info(): dict<any>
  const info = getjumplist()
  return { jumplist: info[0], current_position: info[1] }
enddef

def s:jumplist_to_candidates(jumplist: list<dict<any>>, options: dict<any> = {}): list<string>
  const direction    = get(options, "direction", 1)
  const index_offset = get(options, "index_offset", 0)
  const index_width  = len(len(jumplist) - 1) + (direction <# 0 ? 1 : 0)
  const format       = "%" .. string(index_width) .. "d:%s:%d:%d"

  return jumplist->mapnew((i, bufinfo) => (
    printf(format, (i + index_offset) * direction, s:bufnr_to_filepath(bufinfo.bufnr), bufinfo.lnum, bufinfo.col)
  ))
enddef

def s:bufnr_to_filepath(bufnr: number): string
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

def s:handler(candidate: string): void
  const index = candidate->trim()->matchstr('\v^-?\d+')->str2nr()

  if index <# 0
    printf("%d\<C-o>", index * -1)->feedkeys()
  else
    printf("%d\<C-i>", index)->feedkeys()
  endif
enddef
