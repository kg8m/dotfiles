vim9script

import autoload "kg8m/util.vim"
import autoload "kg8m/util/tmux.vim" as tmuxUtil

export def ExecuteCommand(command: string): void
  if util.OnTmux()
    tmuxUtil.ExecuteCommand(command)
  else
    if len(term_list()) ==# 0
      terminal
    endif

    term_sendkeys(term_list()[0], $"{command}\<CR>")
  endif
enddef
