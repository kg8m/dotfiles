vim9script

final s:cache = {}

def kg8m#util#file#current_name(): string
  return expand("%:t")
enddef

def kg8m#util#file#current_path(): string
  const raw_filepath = expand("%")
  return empty(raw_filepath) ? "" : raw_filepath->kg8m#util#file#format_path()
enddef

def kg8m#util#file#current_relative_path(): string
  return expand("%:~:.")
enddef

def kg8m#util#file#current_absolute_path(): string
  return expand("%:~")
enddef

def kg8m#util#file#format_path(filepath: string): string
  if !has_key(s:cache, "regular_filepath_format")
    s:cache.regular_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
  endif

  return fnamemodify(filepath, s:cache.regular_filepath_format)
enddef

def kg8m#util#file#is_descendant(filepath: string, base: string = getcwd()): bool
  const absolute_filepath = fnamemodify(filepath, ":p")
  const absolute_basepath = fnamemodify(base, ":p")

  return kg8m#util#string#starts_with(absolute_filepath, absolute_basepath)
enddef
