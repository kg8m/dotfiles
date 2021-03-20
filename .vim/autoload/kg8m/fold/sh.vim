vim9script

# Syntax-based folding gets broken depending on syntax-brokenness.
# This `kg8m#fold#sh#expr` is based on some keywords and symbols instead.
#   - keywords: `if`, `fi`, `case`, `esac`, `for`, done, and so on
#   - other supports:
#     - here-documents: `<< FOO ... FOO`
#     - `{ ... }`

const EMPTY_STRING = ""
const COMMENT_CHAR = "#"

const HEREDOC_START_PATTERN = '\v\<\<-?\s*\zs\w+'

const FOLD_START_PATTERN = '\v^%(if|case|for|while)>|\|\s*while>|\{$'
const FOLD_END_PATTERN   = '\v^%(%(fi|esac|done)>|\})'
const ONE_LINER_PATTERN  = '\v<%(fi|esac|done)>'

def kg8m#fold#sh#expr(lnum: number): string
  const line = getline(lnum)->trim()

  if s:is_heredoc_end(line)
    unlet! b:sh_fold_heredoc_key
    return "s1"
  elseif s:is_in_heredoc(line)
    return "="
  elseif s:is_no_content(line)
    return "="
  elseif s:is_fold_end(line)
    return "s1"
  elseif s:is_heredoc_start(line)
    b:sh_fold_heredoc_key = matchstr(line, HEREDOC_START_PATTERN)
    return "a1"
  elseif s:is_fold_start(line)
    return "a1"
  else
    return "="
  endif
enddef

def s:is_no_content(line: string): bool
  return line ==# EMPTY_STRING || kg8m#util#string#starts_with(line, COMMENT_CHAR)
enddef

def s:is_fold_start(line: string): bool
  return !!(line =~# FOLD_START_PATTERN && line !~# ONE_LINER_PATTERN)
enddef

def s:is_fold_end(line: string): bool
  return !!(line =~# FOLD_END_PATTERN)
enddef

def s:is_heredoc_start(line: string): bool
  return !!(line =~# HEREDOC_START_PATTERN)
enddef

def s:is_heredoc_end(line: string): bool
  return !!has_key(b:, "sh_fold_heredoc_key") && line ==# b:sh_fold_heredoc_key
enddef

# Call this only if `s:is_heredoc_end()` returns `false`
def s:is_in_heredoc(line: string): bool
  return !!has_key(b:, "sh_fold_heredoc_key")
enddef
