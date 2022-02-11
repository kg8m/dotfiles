vim9script

final s:cache = {}

def kg8m#util#string#vital(): dict<func>
  if has_key(s:cache, "vital")
    return s:cache.vital
  endif

  s:cache.vital = vital#vital#import("Data.String")
  return s:cache.vital
enddef

# https://github.com/vim-jp/vital.vim/blob/5828301d6bae0858e9ea21012913544f5ef8e375/autoload/vital/__vital__/Data/String.vim#L48-L50
# Re-implement because vital.vim's `Vital.Data.String.starts_with()` is 5-6 times slower.
# (fast) direct `stridx()` >> `kg8m#util#string#starts_with()` > regexp (`=~#`) >>>>> `Vital.Data.String.starts_with()` (slow)
def kg8m#util#string#starts_with(string: string, prefix: string): bool
  return stridx(string, prefix) ==# 0
enddef

# https://github.com/vim-jp/vital.vim/blob/5828301d6bae0858e9ea21012913544f5ef8e375/autoload/vital/__vital__/Data/String.vim#L52-L55
def kg8m#util#string#ends_with(string: string, suffix: string): bool
  const index = strridx(string, suffix)
  return index >=# 0 && index + len(suffix) ==# len(string)
enddef

def kg8m#util#string#includes(string: string, query: string): bool
  return stridx(string, query) >=# 0
enddef
