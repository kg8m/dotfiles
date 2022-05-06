vim9script

def OpenDiffWindow(): void
  if has_key(b:, "diff_window_opened")
    return
  endif

  b:diff_window_opened = true

  setlocal nosplitright
  vnew

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
  redraw!
  wincmd R
  wincmd p
  goto 1
  redraw!
enddef

set nowarn

OpenDiffWindow()
set nowritebackup
