vim9script

final cache = {}

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source: () => OnSource(),
  })
enddef

def UpdateSearchStatus(): void
  timer_stop(get(cache, "timer", -1))
  cache.timer = timer_start(100, (_) => ForceUpdateSearchStatus())
enddef

def ForceUpdateSearchStatus(): void
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
enddef

def OnSource(): void
  g:hitspop_line       = "winbot"
  g:hitspop_line_mod   = -1
  g:hitspop_column     = "winright"
  g:hitspop_column_mod = -2
  g:hitspop_maxwidth   = 50
  g:hitspop_timeout    = 100

  augroup vimrc-plugin-hitspop
    autocmd!
    autocmd CmdlineChanged /            UpdateSearchStatus()
    autocmd User search_start           hitspop#main()
    autocmd User clear_search_highlight hitspop#clean()
  augroup END
enddef
