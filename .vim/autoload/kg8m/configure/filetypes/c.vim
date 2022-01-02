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

  const command = printf(
    "execute_commands_with_echo \"gcc %s -o %s\" \"%s\"",
    current->shellescape(),
    executable->shellescape(),
    ("./" .. executable)->shellescape()
  )
  kg8m#util#terminal#execute_command(command)
enddef
