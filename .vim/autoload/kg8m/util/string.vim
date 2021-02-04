vim9script

final s:cache = {}

def kg8m#util#string#vital(): dict<func>  # {{{
  if has_key(s:cache, "vital")
    return s:cache.vital
  endif

  s:cache.vital = vital#vital#import("Data.String")
  return s:cache.vital
enddef  # }}}
