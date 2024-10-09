vim9script

import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/logger.vim"
import autoload "kg8m/util/qf.vim" as qfUtil

# cf. zsh’s my_grep:with_filter
export def BuildQflistFromBuffer(query_fpath: string, result_fpath: string): void
  if fnamemodify(query_fpath, ":t") !~# '\v^grep\.query\.\w{10}$'
    logger.Error($"The query filepath may not be for grep: {query_fpath}")
    return
  endif

  execute "edit" fnameescape(query_fpath)
  const query = getline(1)
  bdelete

  if fnamemodify(result_fpath, ":t") !~# '\v^grep\.result\.\w{10}$'
    logger.Error($"The result filepath may not be for grep: {result_fpath}")
    return
  endif

  execute "edit" fnameescape(result_fpath)

  if &filetype !=# ""
    logger.Error($"The buffer has filetype: {&filetype}")
    return
  endif

  const lines = getline(1, "$")

  BuildQflistFromLines(query, lines, (qfcontents) => {
    bdelete!

    noswapfile edit grep://source_buffer
    setline(1, lines)

    setlocal buftype=nofile
    setlocal filetype=grep
    setlocal nomodifiable
    setlocal nomodified

    qfUtil.GoToContent(qfcontents[0])
  })
enddef

export def BuildQflistFromLines(query: string, lines: list<string>, Callback: func): void
  const contents = listUtil.FilterMap(lines, (line) => LineToQfContent(line))

  if empty(contents)
    logger.Error("There are no contents.")
    return
  endif

  Callback(contents)

  if len(contents) ># 1
    setqflist(contents)
    setqflist([], "a", { title: $"Grep: {query}" })
    copen
    wincmd p
  endif
enddef

def LineToQfContent(line: string): any
  const matches = matchlist(line, '\v(.{-1,}):(\d+):(\d+):(.+)')

  if len(matches) <# 5
    logger.Warn($"Ignored invalid line: {string(line)}")
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
