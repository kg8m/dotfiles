vim9script

# Syntax-based folding is too heavy when editing a large file.
# This `kg8m#fold#javascript#Expr` is based on `{ ... }` or `[ ... ]` literals and each line indentation.

const FOLD_START = '\v(\{|\[)\s*$'
const FOLD_END   = '\v^\s*(\}|\])'

export def Expr(): string
  const line = getline(v:lnum)

  if line =~# FOLD_START
    return ">" .. string(IndentLevel(v:lnum))
  elseif line =~# FOLD_END
    return "<" .. string(IndentLevel(v:lnum))
  else
    return "="
  endif
enddef

def IndentLevel(lnum: number): number
  return indent(lnum) / &shiftwidth + 1
enddef
