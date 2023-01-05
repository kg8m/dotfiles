vim9script

import autoload "kg8m/util/terminal.vim" as terminalUtil

export def Run(): void
  augroup vimrc-configure-filetypes-go
    autocmd!
    autocmd FileType go SetupBuffer()
  augroup END
enddef

def SetupBuffer(): void
  nnoremap <buffer> <Leader>r :call <SID>RunCurrent()<CR>
enddef

def RunCurrent(): void
  write

  const command = printf("go run -race %s", expand("%")->shellescape())
  terminalUtil.ExecuteCommand(command)
enddef
