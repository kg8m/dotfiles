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
  kg8m#util#terminal#ExecuteCommand(command)
enddef
