vim9script

final s:cache = {}

def kg8m#plugin#completion#disable(): void
  b:asyncomplete_enable = false
enddef

def kg8m#plugin#completion#refresh_pattern(filetype: string): string
  if !has_key(s:cache, "completion_refresh_patterns")
    const css_pattern  = '\v([.#a-zA-Z0-9_-]+)$'
    const ruby_pattern = kg8m#plugin#lsp#servers#is_available("solargraph") ? '\v(\@?\@\k*|(:)@<!:\k*|\k+)$' : '\v(\k+)$'
    const sh_pattern   = '\v((\k|-)+)$'

    s:cache.completion_refresh_patterns = {
      _:    '\v(\k+)$',
      css:  css_pattern,
      html: '\v(/|\k+)$',
      json: '\v("\k*|\[|\k+)$',
      less: css_pattern,
      ruby: ruby_pattern,
      sass: css_pattern,
      scss: css_pattern,
      sh:   sh_pattern,
      sql:  '\v( \zs\k*|[a-zA-Z0-9_-]+)$',
      vue:  '\v([a-zA-Z0-9_-]+|/|\k+)$',
      zsh:  sh_pattern,
    }
  endif

  return get(s:cache.completion_refresh_patterns, filetype) ?? get(s:cache.completion_refresh_patterns, "_")
enddef

def kg8m#plugin#completion#set_refresh_pattern(): void
  if !has_key(b:, "asyncomplete_refresh_pattern")
    const filetype = kg8m#plugin#lsp#is_target_buffer() && kg8m#plugin#lsp#is_buffer_enabled() ? &filetype : "_"
    b:asyncomplete_refresh_pattern = kg8m#plugin#completion#refresh_pattern(filetype)
  endif
enddef

def kg8m#plugin#completion#reset_refresh_pattern(): void
  unlet! b:asyncomplete_refresh_pattern
  kg8m#plugin#completion#set_refresh_pattern()
enddef

def kg8m#plugin#completion#refresh(wait: number = 200): void
  s:stop_refresh_timer()
  s:start_refresh_timer(wait)
enddef

def kg8m#plugin#completion#force_refresh(): void
  asyncomplete#_force_refresh()
  s:stop_refresh_timer()
enddef

def s:start_refresh_timer(wait: number): void
  s:cache.refresh_timer = timer_start(wait, (_) => kg8m#plugin#completion#force_refresh())
enddef

def s:stop_refresh_timer(): void
  timer_stop(get(s:cache, "refresh_timer", -1))
enddef
