vim9script

# cf. zsh's my_grep_with_filter
def kg8m#util#grep#build_qflist_from_buffer(): void
  const filename = expand("%:t")

  if !empty(filename) && filename !~# '\v^tmp\.\w+\.grep$'
    kg8m#util#logger#error("The buffer may not be for grep: " .. filename)
    return
  endif

  if &filetype !=# ""
    kg8m#util#logger#error("The buffer has filetype: " .. &filetype)
    return
  endif

  const lines = getline(1, "$")

  const contents = kg8m#util#list#filter_map(lines, (line) => s:line_to_qf_content(line))

  if empty(contents)
    kg8m#util#logger#error("There are no contents.")
    return
  endif

  bdelete!

  edit grep://source_buffer
  setline(1, lines)

  setlocal buftype=nofile
  setlocal filetype=grep
  setlocal nomodifiable
  setlocal nomodified

  execute "edit " .. fnameescape(contents[0].filename)
  cursor(contents[0].lnum, contents[0].col)

  # zv: Show cursor even if in fold.
  # zz: Adjust cursor at center of window.
  normal! zvzz

  if len(contents) ># 1
    setqflist(contents)
    copen
    wincmd p
  endif
enddef

def s:line_to_qf_content(line: string): any
  const matches = matchlist(line, '\v(.{-1,}):(\d+):(\d+):(.+)')

  if len(matches) <# 5
    kg8m#util#logger#warn("Ignored invalid line: " .. string(line))
    return false
  else
    return {
      filename: matches[1],
      lnum:     matches[2]->str2nr(),
      col:      matches[3]->str2nr(),
      text:     matches[4],
    }
  endif
enddef
