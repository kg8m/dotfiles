vim9script

const PATTERN = '^\s*\(context\|describe\|it\)\>'

def kg8m#plugin#fzf#rspec#outline(): void
  if expand("%") !~# '\w_spec\.rb$'
    kg8m#util#logger#error("Not an RSpec file.")
    return
  endif

  const options = [
    "--preview-window", "down:50%:wrap:nohidden:+{1}-/2",
    "--preview", printf("$FZF_VIM_PATH/bin/preview.sh %s:{1}", expand("%")),
  ]

  fzf#vim#buffer_lines(PATTERN, { options: options })
enddef
