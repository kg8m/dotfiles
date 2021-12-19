vim9script

def kg8m#util#terminal#execute_command(command: string): void
  if kg8m#util#on_tmux()
    kg8m#plugin#vimux#run_command(command)
  else
    if len(term_list()) ==# 0
      terminal
    endif

    term_sendkeys(term_list()[0], command .. "\<CR>")
  endif
enddef
