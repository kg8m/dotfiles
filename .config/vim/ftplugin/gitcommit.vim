vim9script noclear

if exists("*Run")
  finish
endif

def Run(): void
  set nowritebackup
  vnew

  PutLogs()

  wincmd R
  wincmd h
  goto 1
  redraw!

  # Enable language servers.
  edit
enddef

def PutLogs(): void
  setlocal filetype=git
  setlocal bufhidden=delete
  setlocal nobackup
  setlocal noswapfile
  setlocal nobuflisted
  setlocal wrap
  setlocal buftype=nofile

  :0read !git log --max-count=100

  setlocal nomodifiable

  goto 1
enddef

Run()
