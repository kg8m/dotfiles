vim9script

# Syntax-based folding gets broken depending on syntax-brokenness.
# This `kg8m#fold#sh#Expr` is based on some keywords and symbols instead.
#   - keywords: `if`, `fi`, `case`, `esac`, `for`, done, and so on
#   - other supports:
#     - here-documents: `<< FOO ... FOO`
#     - `{ ... }`

import autoload "kg8m/util/string.vim" as stringUtil

const EMPTY_STRING = ""
const COMMENT_CHAR = "#"

const HEREDOC_START_PATTERN = '\v\<\<-?\s*\zs\w+'

const FOLD_START_PATTERN = '\v^%(if|case|for|while)>|\|\s*while>|\{$'
const FOLD_END_PATTERN   = '\v^%(%(fi|esac|done)>|\})'
const ONE_LINER_PATTERN  = '\v<%(fi|esac|done)>'

export def Expr(): string
  const line = getline(v:lnum)->trim()

  if IsHeredocEnd(line)
    unlet! w:sh_fold_heredoc_key
    return "s1"
  elseif IsInHeredoc(line)
    return "="
  elseif IsNoContent(line)
    return "="
  elseif IsFoldEnd(line)
    return "s1"
  elseif IsHeredocStart(line)
    w:sh_fold_heredoc_key = matchstr(line, HEREDOC_START_PATTERN)
    return "a1"
  elseif IsFoldStart(line)
    return "a1"
  else
    return "="
  endif
enddef

def IsNoContent(line: string): bool
  return line ==# EMPTY_STRING || stringUtil.StartsWith(line, COMMENT_CHAR)
enddef

def IsFoldStart(line: string): bool
  return !!(line =~# FOLD_START_PATTERN && line !~# ONE_LINER_PATTERN)
enddef

def IsFoldEnd(line: string): bool
  return !!(line =~# FOLD_END_PATTERN)
enddef

def IsHeredocStart(line: string): bool
  return !!(line =~# HEREDOC_START_PATTERN)
enddef

def IsHeredocEnd(line: string): bool
  return !!has_key(w:, "sh_fold_heredoc_key") && line ==# w:sh_fold_heredoc_key
enddef

# Call this only if `IsHeredocEnd()` returns `false`
def IsInHeredoc(line: string): bool
  return !!has_key(w:, "sh_fold_heredoc_key")
enddef
