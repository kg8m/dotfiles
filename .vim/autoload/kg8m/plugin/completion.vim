function kg8m#plugin#completion#refresh_pattern(filetype) abort  " {{{
  if !has_key(s:, "completion_refresh_patterns")
    let css_pattern = '\v([.#a-zA-Z0-9_-]+)$'
    let sh_pattern  = '\v((\k|-)+)$'

    let s:completion_refresh_patterns = #{
    \   _:    '\v(\k+)$',
    \   css:  css_pattern,
    \   html: '\v(/|\k+)$',
    \   json: '\v("\k*|\[|\k+)$',
    \   less: css_pattern,
    \   ruby: '\v(\@?\@\k*|(:)@<!:\k*|\k+)$',
    \   sass: css_pattern,
    \   scss: css_pattern,
    \   sh:   sh_pattern,
    \   sql:  '\v( \zs\k*|[a-zA-Z0-9_-]+)$',
    \   vue:  '\v([a-zA-Z0-9_-]+|/|\k+)$',
    \   zsh:  sh_pattern,
    \ }
  endif

  return get(s:completion_refresh_patterns, a:filetype, s:completion_refresh_patterns["_"])
endfunction  " }}}

function kg8m#plugin#completion#set_refresh_pattern() abort  " {{{
  if !has_key(b:, "asyncomplete_refresh_pattern")
    let b:asyncomplete_refresh_pattern = kg8m#plugin#completion#refresh_pattern(&filetype)
  endif
endfunction  " }}}

function kg8m#plugin#completion#define_refresh_mappings() abort  " {{{
  call kg8m#plugin#mappings#define_bs_for_insert_mode()
endfunction  " }}}

function kg8m#plugin#completion#define_mappings() abort  " {{{
  call kg8m#plugin#mappings#define_cr_for_insert_mode()
  call kg8m#plugin#mappings#define_tab_for_insert_mode()
endfunction  " }}}

function kg8m#plugin#completion#refresh() abort  " {{{
  call s:stop_refresh_timer()
  call s:start_refresh_timer()
  return ""
endfunction  " }}}

function kg8m#plugin#completion#force_refresh(_timer_id) abort  " {{{
  call asyncomplete#_force_refresh()
  call s:stop_refresh_timer()
endfunction  " }}}

function s:start_refresh_timer() abort  " {{{
  let s:refresh_timer = timer_start(200, "kg8m#plugin#completion#force_refresh")
endfunction  " }}}

function s:stop_refresh_timer() abort  " {{{
  if has_key(s:, "refresh_timer")
    call timer_stop(s:refresh_timer)
    unlet s:refresh_timer
  endif
endfunction  " }}}
