vim9script

final s:cache = {}

export def CurrentName(): string
  return expand("%:t")
enddef

export def CurrentPath(): string
  const raw_filepath = expand("%")
  return empty(raw_filepath) ? "" : raw_filepath->kg8m#util#file#FormatPath()
enddef

export def CurrentRelativePath(): string
  return expand("%:~:.")
enddef

export def CurrentAbsolutePath(): string
  return expand("%:~")
enddef

export def FormatPath(filepath: string): string
  if !has_key(s:cache, "regular_filepath_format")
    s:cache.regular_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
  endif

  return fnamemodify(filepath, s:cache.regular_filepath_format)
enddef

export def IsDescendant(filepath: string, base: string = getcwd()): bool
  const absolute_filepath = fnamemodify(filepath, ":p")
  const absolute_basepath = fnamemodify(base, ":p")

  return kg8m#util#string#StartsWith(absolute_filepath, absolute_basepath)
enddef
