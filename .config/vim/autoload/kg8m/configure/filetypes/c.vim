vim9script

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

  const current    = kg8m#util#file#CurrentRelativePath()
  const executable = fnamemodify(current, ":r")

  const included_files = getline(1, "$")->kg8m#util#list#FilterMap((line): any => {
    if line =~# '\v^#include ".+\.h"$'
      return matchstr(line, '\v"\zs.+\ze"')->fnamemodify(":r") .. ".c"
    else
      return false
    endif
  })

  const command = printf(
    "execute_commands_with_echo \"gcc %s %s -o %s\" \"%s\"",
    current->shellescape(),
    included_files->mapnew((_, file) => shellescape(file))->join(" "),
    executable->shellescape(),
    ("./" .. executable)->shellescape()
  )
  kg8m#util#terminal#ExecuteCommand(command)
enddef
