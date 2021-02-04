vim9script

final s:cache = {}

def kg8m#util#string#vital(): dict<func>  # {{{
  if has_key(s:cache, "vital")
    return s:cache.vital
  endif

  s:cache.vital = vital#vital#import("Data.String")
  return s:cache.vital
enddef  # }}}

# vital.vim's `Vital.Data.String.starts_with()` is 5-6 times slower.
# (fast) direct `stridx()` >> `kg8m#util#string#starts_with()` > regexp (`=~#`) >>>>> `Vital.Data.String.starts_with()` (slow)
def kg8m#util#string#starts_with(string: string, prefix: string): bool
  return stridx(string, prefix) ==# 0
enddef
