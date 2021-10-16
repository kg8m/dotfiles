vim9script

final s:cache = {}

def kg8m#plugin#asyncomplete#buffer#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  "asyncomplete.vim",
    hook_post_source: () => s:on_post_source(),
  })
enddef

# https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L51-L57
def s:on_event(): void
  if !get(s:cache, "is_refresh_keywords_defined", false)
    s:setup_refresh_keywords()
  endif

  s:cache.refresh_keywords()
  s:stop_refresh_timer()
enddef

def s:on_event_async(): void
  s:stop_refresh_timer()
  s:start_refresh_timer()
enddef

def s:start_refresh_timer(): void
  s:cache.refresh_timer = timer_start(200, (_) => s:on_event())
enddef

def s:stop_refresh_timer(): void
  timer_stop(get(s:cache, "refresh_timer", -1))
enddef

def s:setup_refresh_keywords(): void
  var asyncomplete_buffer_sid = ""

  for scriptname in split(execute("scriptnames"), '\n')
    if scriptname =~# 'asyncomplete-buffer\.vim/autoload/asyncomplete/sources/buffer\.vim'
      asyncomplete_buffer_sid = matchstr(scriptname, '\v^ *(\d+)')
      break
    endif
  endfor

  if empty(asyncomplete_buffer_sid)
    s:cache.refresh_keywords = function("s:cannot_refresh_keywords")
  else
    s:cache.refresh_keywords = function("<SNR>" .. asyncomplete_buffer_sid .. "_refresh_keywords")
  endif

  s:cache.is_refresh_keywords_defined = true
enddef

def s:cannot_refresh_keywords(): void
  kg8m#util#logger#error("Cannot refresh keywords because asyncomplete-buffer.vim's SID can't be detected.")
enddef

def s:activate(): void
  s:on_event_async()
enddef

def s:on_post_source(): void
  # Call asyncomplete-buffer.vim's function to refresh keywords (`s:cache.refresh_keywords`) on some events not only
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
    on_event: (..._) => s:on_event_async(),
    priority: 2,
  }))

  s:activate()
enddef
