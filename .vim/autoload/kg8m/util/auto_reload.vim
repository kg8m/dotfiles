vim9script

export def Setup(): void
  augroup vimrc-util-auto_reload
    autocmd!
    autocmd VimEnter * timer_start(3000, (_) => Checktime(), { repeat: -1 })
  augroup END
enddef

def Checktime(): void
  try
    # `checktime` is not available in Command Line mode
    if !getcmdwintype()->empty()
      return
    endif

    checktime
  # Sometimes `checktime` raise an error
  #   - e.g., E565: "Not allowed to change text or change window" when using vim-sandwich
  catch /^Vim\%((\a\+)\)\=:E565:/
    # Do nothing
  endtry
enddef
