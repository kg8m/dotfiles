vim9script

# This `kg8m#fold#rbs#Expr` is based on keywords and each line indent instead.
#   - keywords: `class`, `module`, `interface`, `end`, and so on

import autoload "kg8m/util/string.vim" as stringUtil

const EMPTY_STRING = ""
const COMMENT_CHAR = "#"

const FOLD_START_PATTERN = '\v^%(class|module|interface)>'
const FOLD_END_PATTERN = '\v^end>'

export def Expr(): string
  const line = getline(v:lnum)->trim()

  if IsNoContent(line)
    return "="
  elseif IsFoldEnd(line)
    return "<" .. string(IndentLevel(v:lnum))
  elseif IsFoldStart(line)
    return ">" .. string(IndentLevel(v:lnum))
  else
    # Return stringified number because Vim9 script currently doesn’t support `string | number` return type
    return string(IndentLevel(v:lnum) - 1)
  endif
enddef

def IndentLevel(lnum: number): number
  return indent(lnum) / &shiftwidth + 1
enddef

def IsNoContent(line: string): bool
  return line ==# EMPTY_STRING || stringUtil.StartsWith(line, COMMENT_CHAR)
enddef

def IsFoldStart(line: string): bool
  return !!(line =~# FOLD_START_PATTERN)
enddef

def IsFoldEnd(line: string): bool
  return !!(line =~# FOLD_END_PATTERN)
enddef
