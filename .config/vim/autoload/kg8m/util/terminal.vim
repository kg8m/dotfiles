vim9script

export def ExecuteCommand(command: string): void
  if kg8m#util#OnTmux()
    kg8m#plugin#vimux#RunCommand(command)
  else
    if len(term_list()) ==# 0
      terminal
    endif

    term_sendkeys(term_list()[0], $"{command}\<CR>")
  endif
enddef
