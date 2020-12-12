function kg8m#plugin#autodate#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy:     v:true,
  \   on_event: "BufWritePre",
  \   hook_source:      function("s:on_source"),
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

function s:on_source() abort  " {{{
  let g:autodate_format       = "%Y/%m/%d"
  let g:autodate_lines        = 100
  let g:autodate_keyword_pre  = '\c\%('..
  \   '\%(Last \?\%(Change\|Modified\)\)\|'..
  \   '\%(最終更新日\?\)\|'..
  \   '\%(更新日\)'..
  \ '\):'
  let g:autodate_keyword_post = '\.$'
endfunction  " }}}

function s:on_post_source() abort  " {{{
  Autodate
endfunction  " }}}
