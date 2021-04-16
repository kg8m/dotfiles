vim9script

final s:cache = {}

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
    b:asyncomplete_refresh_pattern = kg8m#plugin#completion#refresh_pattern(&filetype)
  endif
enddef

def kg8m#plugin#completion#define_refresh_mappings(): void
  kg8m#plugin#mappings#define_bs_for_insert_mode()
enddef

def kg8m#plugin#completion#define_mappings(): void
  kg8m#plugin#mappings#define_cr_for_insert_mode()
  kg8m#plugin#mappings#define_tab_for_insert_mode()
enddef

def kg8m#plugin#completion#refresh(): string
  s:stop_refresh_timer()
  s:start_refresh_timer()
  return ""
enddef

def kg8m#plugin#completion#force_refresh(): void
  asyncomplete#_force_refresh()
  s:stop_refresh_timer()
enddef

def s:start_refresh_timer(): void
  s:cache.refresh_timer = timer_start(200, (_) => kg8m#plugin#completion#force_refresh())
enddef

def s:stop_refresh_timer(): void
  timer_stop(get(s:cache, "refresh_timer"))
enddef
