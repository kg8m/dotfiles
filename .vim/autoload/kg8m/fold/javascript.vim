vim9script

# Syntax-based folding is too heavy when editing a large file.
# This `kg8m#fold#javascript#expr` is based on `{ ... }` or `[ ... ]` literals and each line indentation.

const FOLD_START = '\v(\{|\[)\s*$'
const FOLD_END   = '\v^\s*(\}|\])'

def kg8m#fold#javascript#expr(lnum: number): string
  const line = getline(lnum)

  if line =~# FOLD_START
    return ">" .. string(s:indent_level(lnum))
  elseif line =~# FOLD_END
    return "<" .. string(s:indent_level(lnum))
  else
    return "="
  endif
enddef

def s:indent_level(lnum: number): number
  return indent(lnum) / &shiftwidth + 1
enddef
