vim9script

def kg8m#configure#filetypes#go#run(): void
  augroup vimrc-configure-filetypes-go
    autocmd!
    autocmd FileType go s:setup_buffer()
  augroup END
enddef

def s:setup_buffer(): void
  nnoremap <buffer> <Leader>r :call <SID>run_current()<CR>
enddef

def s:run_current(): void
  write

  const command = printf("go run -race %s", expand("%")->shellescape())
  kg8m#util#terminal#execute_command(command)
enddef
