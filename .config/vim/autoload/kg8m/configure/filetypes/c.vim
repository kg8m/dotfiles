vim9script

import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/terminal.vim" as terminalUtil

export def Run(): void
  augroup vimrc-configure-filetypes-c
    autocmd!
    autocmd FileType c SetupBuffer()
  augroup END
enddef

def SetupBuffer(): void
  nnoremap <buffer> <Leader>r :call <SID>RunCurrent()<CR>
enddef

def RunCurrent(): void
  write

  const current    = fileUtil.CurrentRelativePath()
  const executable = fnamemodify(current, ":r")

  const included_files = getline(1, "$")->listUtil.FilterMap((line): any => {
    if line =~# '\v^#include ".+\.h"$'
      const filepath_without_extension = matchstr(line, '\v"\zs.+\ze"')->fnamemodify(":r")
      return $"{filepath_without_extension}.c"
    else
      return false
    endif
  })

  const command = printf(
    "execute_commands_with_echo \"gcc %s %s -o %s\" \"%s\"",
    shellescape(current),
    included_files->mapnew((_, file) => shellescape(file))->join(" "),
    shellescape(executable),
    shellescape($"./{executable}")
  )
  terminalUtil.ExecuteCommand(command)
enddef
