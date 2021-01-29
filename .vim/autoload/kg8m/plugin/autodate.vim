vim9script

def kg8m#plugin#autodate#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy:     true,
    on_event: "BufWritePre",
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef  # }}}

def s:on_source(): void  # {{{
  g:autodate_format       = "%Y/%m/%d"
  g:autodate_lines        = 100
  g:autodate_keyword_pre  =
    '\c\%(' ..
      '\%(Last \?\%(Change\|Modified\)\)\|' ..
      '\%(最終更新日\?\)\|' ..
      '\%(更新日\)' ..
    '\):'
  g:autodate_keyword_post = '\.$'
enddef  # }}}

def s:on_post_source(): void  # {{{
  # Use `execute` because `Autodate` command causes "E476: Invalid command: Autodate"
  execute "Autodate"
enddef  # }}}
