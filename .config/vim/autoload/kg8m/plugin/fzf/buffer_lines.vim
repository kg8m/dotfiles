vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/logger.vim"
import autoload "kg8m/util/qf.vim" as qfUtil

# Wrapper function to colorize lines and show preview around each line (fzf’s `:BLines` doesn’t)
export def Run(query: string = ""): void
  const filepath = expand("%")

  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  Source(),
    "sink*": BuildHandler(filepath),
    options: [
      "--prompt", "BLines> ",
      "--preview", $"preview {shellescape(filepath)}:{{1}}",
      "--preview-window", "down:50%:wrap:nohidden:+{1}-/2",
      "--query", query,
    ],
  }

  fzf#run(fzf#wrap("buffer-lines", options))
enddef

def Source(): string
  const tempfile = system("mktemp")->trim()
  silent execute "write!" tempfile

  timer_start(1000, (_) => delete(tempfile))

  const bat_args = [
    "--file-name", shellescape(expand("%")),
    "--wrap", "never",
    "--color", "always",
    "--paging", "never",
    "--style", "numbers",
    shellescape(tempfile),
  ]

  return $"bat {join(bat_args, " ")}"
enddef

def BuildHandler(filepath: string): func(list<string>): void
  return (lines: list<string>) => Handler(filepath, lines)
enddef

def Handler(filepath: string, lines: list<string>): void
  const qfcontents = listUtil.FilterMap(lines, (line) => LineToQfContent(filepath, line))

  if empty(qfcontents)
    logger.Warn("There are no contents.")
    return
  endif

  qfUtil.GoToContent(qfcontents[0])

  if len(qfcontents) ># 1
    setqflist(qfcontents)
    setqflist([], "a", { title: $"BufferLines for {filepath}" })
    copen
    wincmd p
  endif
enddef

def LineToQfContent(filepath: string, line: string): any
  const matches = matchlist(line, '\v^\s*(\d+)\s+(.+)$')

  if len(matches) <# 3
    return false
  else
    return {
      filename: filepath,
      lnum:     matches[1]->str2nr(),
      col:      1,
      text:     matches[2],
    }
  endif
enddef

plugin.EnsureSourced("fzf.vim")
