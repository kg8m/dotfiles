vim9script

const PATTERN = '^\s*\(context\|describe\|it\)\>'

export def Outline(): void
  if expand("%") !~# '\w_spec\.rb$'
    kg8m#util#logger#Error("Not an RSpec file.")
    return
  endif

  kg8m#plugin#fzf#buffer_lines#Run(PATTERN)
enddef
