vim9script

import autoload "kg8m/util/logger.vim"

final cache = {}

export def Vital(): dict<func>
  if has_key(cache, "vital")
    return cache.vital
  endif

  cache.vital = vital#vital#import("Data.String")
  return cache.vital
enddef

# https://github.com/vim-jp/vital.vim/blob/5828301d6bae0858e9ea21012913544f5ef8e375/autoload/vital/__vital__/Data/String.vim#L48-L50
# Re-implement because vital.vim's `Vital.Data.String.starts_with()` is 5-6 times slower.
# (fast) direct `stridx()` >> `kg8m#util#string#StartsWith()` > regexp (`=~#`) >>>>> `Vital.Data.String.starts_with()` (slow)
export def StartsWith(string: string, prefix: string): bool
  return stridx(string, prefix) ==# 0
enddef

# https://github.com/vim-jp/vital.vim/blob/5828301d6bae0858e9ea21012913544f5ef8e375/autoload/vital/__vital__/Data/String.vim#L52-L55
export def EndsWith(string: string, suffix: string): bool
  const index = strridx(string, suffix)
  return index >=# 0 && index + len(suffix) ==# len(string)
enddef

export def Includes(string: string, query: string): bool
  return stridx(string, query) >=# 0
enddef

# vital.vim's `truncate()` and `truncate_skipping()` is a little slow.
# So use `printf()` with `%.*S` unless `footer_width` of `truncate_skipping()` is unnecessary.
export def Truncate(string: string, max_width: number, options: dict<any> = {}): string
  const skipper = get(options, "skipper", "...")
  const skipper_width = strdisplaywidth(skipper)

  if skipper_width ># max_width
    const prefix = "[kg8m#util#string#Truncate()]"
    const message = $"Skipper width ({skipper_width}) is greater than max width ({max_width})."

    logger.Error($"{prefix} {message}")
    return string
  endif

  if strdisplaywidth(string) <=# max_width
    return string
  else
    const footer_width = get(options, "footer_width", 0)

    if !!footer_width
      return Vital().truncate_skipping(string, max_width, footer_width, skipper)
    else
      return printf($"%.{max_width - skipper_width}S%s", string, skipper)
    endif
  endif
enddef
