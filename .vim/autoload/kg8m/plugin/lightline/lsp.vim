function kg8m#plugin#lightline#lsp#configure() abort  " {{{
  let g:lightline#lsp#indicator_error       = "E:"
  let g:lightline#lsp#indicator_warning     = "W:"
  let g:lightline#lsp#indicator_information = "I:"
  let g:lightline#lsp#indicator_hint        = "H:"

  " Overwrite
  let elements = kg8m#plugin#lightline#elements()
  let elements.right += [
  \   ["lsp_status_for_error"], ["lsp_status_for_warning"],
  \ ]
  call extend(g:lightline.component_expand, #{
  \   lsp_status_for_error:   "kg8m#plugin#lightline#lsp#status_for_error",
  \   lsp_status_for_warning: "kg8m#plugin#lightline#lsp#status_for_warning",
  \ })
  call extend(g:lightline.component_type, #{
  \   lsp_status_for_error:   "error",
  \   lsp_status_for_warning: "warning",
  \ })

  " Don't load lazily because the `component_expand` doesn't work
  call kg8m#plugin#configure(#{
  \   lazy: v:false,
  \ })
endfunction  " }}}

function kg8m#plugin#lightline#lsp#status() abort  " {{{
  if !s:is_stats_available()
    return ""
  endif

  let stats = s:stats()
  return (stats.is_error || stats.is_warning) ? "" : stats.counts
endfunction  " }}}

function kg8m#plugin#lightline#lsp#status_for_error() abort  " {{{
  " Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#lsp#status_for_error_detail()}"
endfunction  " }}}

function kg8m#plugin#lightline#lsp#status_for_error_detail() abort  " {{{
  if !s:is_stats_available()
    return ""
  endif

  let stats = s:stats()
  return stats.is_error ? stats.counts : ""
endfunction  " }}}

function kg8m#plugin#lightline#lsp#status_for_warning() abort  " {{{
  " Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#lsp#status_for_warning_detail()}"
endfunction  " }}}

function kg8m#plugin#lightline#lsp#status_for_warning_detail() abort  " {{{
  if !s:is_stats_available()
    return ""
  endif

  let stats = s:stats()
  return (!stats.is_error && stats.is_warning) ? stats.counts : ""
endfunction  " }}}

function s:is_stats_available() abort  " {{{
  return kg8m#plugin#lsp#is_target_buffer() && kg8m#plugin#lsp#is_buffer_enabled()
endfunction  " }}}

function s:stats() abort  " {{{
  let error       = lightline#lsp#error()
  let warning     = lightline#lsp#warning()
  let information = lightline#lsp#information()
  let hint        = lightline#lsp#hint()

  let is_error   = !empty(error)
  let is_warning = !empty(warning)

  let error       = empty(error)       ? g:lightline#lsp#indicator_error      .."0" : error
  let warning     = empty(warning)     ? g:lightline#lsp#indicator_warning    .."0" : warning
  let information = empty(information) ? g:lightline#lsp#indicator_information.."0" : information
  let hint        = empty(hint)        ? g:lightline#lsp#indicator_hint       .."0" : hint

  return #{
  \   counts:     join(["[LSP]", error, warning, information, hint], " "),
  \   is_error:   is_error,
  \   is_warning: is_warning,
  \ }
endfunction  " }}}
