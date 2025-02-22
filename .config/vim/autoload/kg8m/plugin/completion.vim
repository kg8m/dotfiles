vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/lsp.vim"
import autoload "kg8m/plugin/lsp/servers.vim" as lspServers

final cache = {}

augroup vimrc-plugin-completion
  autocmd!
  autocmd TextChangedP * RequestToRefresh()
augroup END

export def Disable(): void
  b:asyncomplete_enable = false
enddef

export def RefreshPattern(filetype: string): string
  if !has_key(cache, "completion_refresh_patterns")
    const css_pattern = '\v([.#a-zA-Z0-9_-]+)$'
    const sh_pattern  = '\v((\k|-)+)$'

    cache.completion_refresh_patterns = {
      _:    '\v(\k+)$',
      bash: sh_pattern,
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

def RequestToRefresh(wait: number = 200): void
  StopRefreshTimer()
  StartRefreshTimer(wait)
enddef

def Refresh(): void
  const prev_two_chars = strpart(getline("."), col(".") - 3, 2)

  # Don’t add mappings for this omni-completion because they can conflict with lexima.vim’s configs.
  if &omnifunc ==# "lsp#complete" && prev_two_chars =~# '\v^%(\w\.|[^[:blank:]]\s)$'
    feedkeys("\<C-x>\<C-o>", "t")
  else
    RefreshTagsCandidates()
    StopRefreshTimer()
  endif
enddef

# Refresh the completion candidates from the tags using the latest context whenever the text changes, because they
# aren’t updated automatically when the tags file is modified.
def RefreshTagsCandidates(): void
  if !has_key(cache, "tags_source_info")
    plugin.EnsureSourced("asyncomplete-tags.vim")
    cache.tags_source_info = asyncomplete#get_source_info("tags")
  endif

  cache.tags_source_info.completor(cache.tags_source_info, asyncomplete#context())
enddef

def StartRefreshTimer(wait: number): void
  cache.refresh_timer = timer_start(wait, (_) => Refresh())
enddef

def StopRefreshTimer(): void
  timer_stop(get(cache, "refresh_timer", -1))
enddef
