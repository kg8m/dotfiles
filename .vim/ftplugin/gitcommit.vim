function s:open_diff_window() abort
  if has_key(b:, "diff_window_opened")
    return
  endif

  let b:diff_window_opened = v:true

  setlocal nosplitright
  vnew

  setlocal filetype=git
  setlocal bufhidden=delete
  setlocal nobackup
  setlocal noswapfile
  setlocal nobuflisted
  setlocal wrap
  setlocal buftype=nofile

  read !git log --max-count=100
  call deletebufline(bufnr(), 1, 1)

  setlocal nomodifiable

  goto 1
  redraw!
  wincmd R
  wincmd p
  goto 1
  redraw!
endfunction

set nowarn

call s:open_diff_window()
set nowritebackup
