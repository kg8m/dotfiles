vim9script

const PATTERN = '^\s*\(context\|describe\|it\)\>'

def kg8m#plugin#fzf#rspec#outline(): void
  if expand("%") !~# '\w_spec\.rb$'
    kg8m#util#logger#error("Not an RSpec file.")
    return
  endif

  kg8m#plugin#fzf#buffer_lines#run(PATTERN)
enddef
