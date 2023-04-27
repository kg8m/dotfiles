vim9script

import autoload "kg8m/plugin/lsp.vim"
import autoload "kg8m/plugin/lsp/servers.vim" as lspServers

final cache = {}

export def Disable(): void
  b:asyncomplete_enable = false
enddef

export def RefreshPattern(filetype: string): string
  if !has_key(cache, "completion_refresh_patterns")
    const css_pattern = '\v([.#a-zA-Z0-9_-]+)$'
    const sh_pattern  = '\v((\k|-)+)$'

    cache.completion_refresh_patterns = {
      _:    '\v(\k+)$',
      css:  css_pattern,
      html: '\v(/|\k+)$',
      json: '\v("\k*|\[|\k+)$',
      less: css_pattern,
      sass: css_pattern,
      scss: css_pattern,
      sh:   sh_pattern,
      sql:  '\v( \zs\k*|[a-zA-Z0-9_-]+)$',
      vue:  '\v([a-zA-Z0-9_-]+|/|\k+)$',
      zsh:  sh_pattern,
    }
  endif

  return get(cache.completion_refresh_patterns, filetype) ?? get(cache.completion_refresh_patterns, "_")
enddef

export def SetRefreshPattern(): void
  if !has_key(b:, "asyncomplete_refresh_pattern")
    const filetype = lsp.IsTargetBuffer() && lsp.IsBufferEnabled() ? &filetype : "_"
    b:asyncomplete_refresh_pattern = RefreshPattern(filetype)
  endif
enddef

export def ResetRefreshPattern(): void
  unlet! b:asyncomplete_refresh_pattern
  SetRefreshPattern()
enddef

export def Refresh(wait: number = 200): void
  StopRefreshTimer()
  StartRefreshTimer(wait)
enddef

def ForceRefresh(): void
  asyncomplete#_force_refresh()
  StopRefreshTimer()
enddef

def StartRefreshTimer(wait: number): void
  cache.refresh_timer = timer_start(wait, (_) => ForceRefresh())
enddef

def StopRefreshTimer(): void
  timer_stop(get(cache, "refresh_timer", -1))
enddef
