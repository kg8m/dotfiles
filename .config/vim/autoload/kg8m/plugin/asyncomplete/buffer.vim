vim9script

final cache = {}

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  "asyncomplete.vim",
    hook_post_source: () => OnPostSource(),
  })
enddef

# https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L51-L57
def OnEvent(): void
  if !get(cache, "is_refresh_keywords_defined", false)
    SetupRefreshKeywords()
  endif

  cache.refresh_keywords()
  StopRefreshTimer()
enddef

def OnEventAsync(): void
  StopRefreshTimer()
  StartRefreshTimer()
enddef

def StartRefreshTimer(): void
  cache.refresh_timer = timer_start(200, (_) => OnEvent())
enddef

def StopRefreshTimer(): void
  timer_stop(get(cache, "refresh_timer", -1))
enddef

def SetupRefreshKeywords(): void
  var asyncomplete_buffer_sid = ""

  for scriptname in split(execute("scriptnames"), "\n")
    if scriptname =~# 'asyncomplete-buffer\.vim/autoload/asyncomplete/sources/buffer\.vim'
      asyncomplete_buffer_sid = matchstr(scriptname, '\v^ *(\d+)')
      break
    endif
  endfor

  if empty(asyncomplete_buffer_sid)
    cache.refresh_keywords = funcref("CannotRefreshKeywords")
  else
    cache.refresh_keywords = function("<SNR>" .. asyncomplete_buffer_sid .. "_refresh_keywords")
  endif

  cache.is_refresh_keywords_defined = true
enddef

def CannotRefreshKeywords(): void
  kg8m#util#logger#Error("Cannot refresh keywords because asyncomplete-buffer.vim's SID can't be detected.")
enddef

def Activate(): void
  OnEventAsync()
enddef

def OnPostSource(): void
  # Call asyncomplete-buffer.vim's function to refresh keywords (`cache.refresh_keywords`) on some events not only
  # `BufWinEnter` in order to include keywords added after `BufWinEnter` in completion candidates
  # https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L29
  const events = [
    "BufWinEnter",
    "TextChanged",
    "TextChangedI",
    "TextChangedP",
  ]

  asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    name: "buffer",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#buffer#completor"),
    events: events,
    on_event: (..._) => OnEventAsync(),
    priority: 2,
  }))

  Activate()
enddef
