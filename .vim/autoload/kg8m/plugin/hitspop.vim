vim9script

final s:cache = {}

def kg8m#plugin#hitspop#configure(): void  # {{{
  g:hitspop_line       = "winbot"
  g:hitspop_line_mod   = -1
  g:hitspop_column     = "winright"
  g:hitspop_column_mod = -2

  augroup my_vimrc  # {{{
    autocmd CmdlineChanged /            s:update_search_status()
    autocmd User search_start           hitspop#main()
    autocmd User clear_search_highlight hitspop#clean()
  augroup END  # }}}
enddef  # }}}

def s:update_search_status(): void  # {{{
  if has_key(s:cache, "timer")
    timer_stop(s:cache.timer)
    remove(s:cache, "timer")
  endif

  s:cache.timer = timer_start(100, () => s:force_update_search_status())
enddef  # }}}

def s:force_update_search_status(): void  # {{{
  if mode() !=# "c"
    return
  endif

  const input = getcmdline()

  if empty(input) || input ==# "\\v"
    @/ = ""
    hitspop#clean()
  else
    @/ = input
    hitspop#main()
  endif
enddef  # }}}
