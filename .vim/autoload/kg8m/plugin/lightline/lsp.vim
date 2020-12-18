vim9script

def kg8m#plugin#lightline#lsp#configure(): void  # {{{
  g:lightline#lsp#indicator_error       = "E:"
  g:lightline#lsp#indicator_warning     = "W:"
  g:lightline#lsp#indicator_information = "I:"
  g:lightline#lsp#indicator_hint        = "H:"

  # Overwrite
  final elements = kg8m#plugin#lightline#elements()
  extend(elements.right, [
    ["lsp_status_for_error"], ["lsp_status_for_warning"],
  ])
  extend(g:lightline.component_expand, {
    lsp_status_for_error:   "kg8m#plugin#lightline#lsp#status_for_error",
    lsp_status_for_warning: "kg8m#plugin#lightline#lsp#status_for_warning",
  })
  extend(g:lightline.component_type, {
    lsp_status_for_error:   "error",
    lsp_status_for_warning: "warning",
  })

  # Don't load lazily because the `component_expand` doesn't work
  kg8m#plugin#configure({
    lazy: v:false,
  })
enddef  # }}}

def kg8m#plugin#lightline#lsp#status(): string  # {{{
  if !s:is_stats_available()
    return ""
  endif

  const stats = s:get_stats()
  return (stats.is_error || stats.is_warning) ? "" : stats.counts
enddef  # }}}

def kg8m#plugin#lightline#lsp#status_for_error(): string  # {{{
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#lsp#status_for_error_detail()}"
enddef  # }}}

def kg8m#plugin#lightline#lsp#status_for_error_detail(): string  # {{{
  if !s:is_stats_available()
    return ""
  endif

  const stats = s:get_stats()
  return stats.is_error ? stats.counts : ""
enddef  # }}}

def kg8m#plugin#lightline#lsp#status_for_warning(): string  # {{{
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#lsp#status_for_warning_detail()}"
enddef  # }}}

def kg8m#plugin#lightline#lsp#status_for_warning_detail(): string  # {{{
  if !s:is_stats_available()
    return ""
  endif

  const stats = s:get_stats()
  return (!stats.is_error && stats.is_warning) ? stats.counts : ""
enddef  # }}}

def s:is_stats_available(): bool  # {{{
  return kg8m#plugin#lsp#is_target_buffer() && kg8m#plugin#lsp#is_buffer_enabled()
enddef  # }}}

def s:get_stats(): dict<any>  # {{{
  var error       = lightline#lsp#error()
  var warning     = lightline#lsp#warning()
  var information = lightline#lsp#information()
  var hint        = lightline#lsp#hint()

  const is_error   = !empty(error)
  const is_warning = !empty(warning)

  error       = empty(error)       ? g:lightline#lsp#indicator_error       .. "0" : error
  warning     = empty(warning)     ? g:lightline#lsp#indicator_warning     .. "0" : warning
  information = empty(information) ? g:lightline#lsp#indicator_information .. "0" : information
  hint        = empty(hint)        ? g:lightline#lsp#indicator_hint        .. "0" : hint

  return {
    counts:     join(["[LSP]", error, warning, information, hint], " "),
    is_error:   is_error,
    is_warning: is_warning,
  }
enddef  # }}}
