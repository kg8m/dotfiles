vim9script

def kg8m#configure#filetypes#c#run(): void
  augroup vimrc-configure-filetypes-c
    autocmd!
    autocmd FileType c s:setup_buffer()
  augroup END
enddef

def s:setup_buffer(): void
  nnoremap <buffer> <Leader>r :call <SID>run_current()<CR>
enddef

def s:run_current(): void
  write

  const current    = kg8m#util#file#current_relative_path()
  const executable = fnamemodify(current, ":r")

  const included_files = getline(1, "$")->kg8m#util#list#filter_map((line): any => {
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
  kg8m#util#terminal#execute_command(command)
enddef
