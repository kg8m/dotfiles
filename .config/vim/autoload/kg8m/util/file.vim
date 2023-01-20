vim9script

import autoload "kg8m/util/string.vim" as stringUtil

final cache = {}

export def CurrentName(): string
  return expand("%:t")->NormalizePath()
enddef

export def CurrentPath(): string
  const raw_filepath = expand("%")
  return empty(raw_filepath) ? "" : raw_filepath->NormalizePath()
enddef

export def CurrentRelativePath(): string
  return expand("%:~:.")->NormalizePath()
enddef

export def CurrentAbsolutePath(): string
  return expand("%:~")->NormalizePath()
enddef

export def NormalizePath(filepath: string): string
  if !has_key(cache, "regular_filepath_format")
    cache.regular_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
  endif

  return fnamemodify(filepath, cache.regular_filepath_format)->simplify()
enddef

export def IsDescendant(filepath: string, base: string = getcwd()): bool
  const absolute_filepath = fnamemodify(filepath, ":p")
  const absolute_basepath = fnamemodify(base, ":p")

  return stringUtil.StartsWith(absolute_filepath, absolute_basepath)
enddef
