vim9script

def kg8m#util#auto_reload#setup(): void
  augroup my_vimrc
    autocmd VimEnter * timer_start(3000, (_) => s:checktime(), { repeat: -1 })
  augroup END
enddef

def s:checktime(): void
  try
    # `checktime` is not available in Command Line mode
    if !getcmdwintype()->empty()
      return
    endif

    :checktime
  # Sometimes `checktime` raise an error
  #   - e.g., E565: "Not allowed to change text or change window" when using vim-sandwich
  catch /^Vim\%((\a\+)\)\=:E565:/
    # Do nothing
  endtry
enddef
