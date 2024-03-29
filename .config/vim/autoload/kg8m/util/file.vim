vim9script

import autoload "kg8m/util/string.vim" as stringUtil

final cache = {}

export def CurrentName(): string
  return expand("%:t")
enddef

export def CurrentPath(): string
  const raw_filepath = expand("%")
  return empty(raw_filepath) ? "" : raw_filepath->NormalizePath()
enddef

export def CurrentRelativePath(): string
  return expand("%")->NormalizePath({ format: ":~:." })
enddef

export def CurrentAbsolutePath(): string
  return expand("%")->NormalizePath({ format: ":~" })
enddef

export def NormalizePath(filepath: string, options: dict<string> = {}): string
  const format = get(options, "format", null) ?? RegularFilepathFormat()
  const normalized_filepath = fnamemodify(filepath, format)

  if stringUtil.Includes(normalized_filepath, "://")
    # Prevent `simplify()` from replacing "://" with ":/".
    const [scheme, body] = split(normalized_filepath, "://")
    return $"{scheme}://{simplify(body)}"
  else
    return simplify(normalized_filepath)
  endif
enddef

def RegularFilepathFormat(): string
  if !has_key(cache, "regular_filepath_format")
    cache.regular_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
  endif

  return cache.regular_filepath_format
enddef

export def IsDescendant(filepath: string, base: string = getcwd()): bool
  const absolute_filepath = fnamemodify(filepath, ":p")
  const absolute_basepath = fnamemodify(base, ":p")

  return stringUtil.StartsWith(absolute_filepath, absolute_basepath)
enddef

export def DetectLineAndColumnInFile(filepath: string, line_pattern: string, column_pattern: string): list<number>
  const command  = ["rg", "--line-number", "--no-filename", line_pattern, filepath]
  const result   = command->mapnew((_, item) => shellescape(item))->join(" ")->system()->trim()

  if empty(result)
    return [0, 0]
  else
    const line_number   = matchstr(result, '\v\d+')->str2nr()
    const column_number = matchstrpos(result, column_pattern)[1] - len(line_number)

    return [line_number, column_number]
  endif
enddef
