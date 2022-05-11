vim9script

# Syntax-based folding gets broken depending on syntax-brokenness.
# This `kg8m#fold#ruby#Expr` is based on keywords and each line indent instead.
#   - keywords: `class`, `def`, `end`, and so on
#   - other supports:
#     - here-documents: `<<FOO ... FOO`
#     - blocks:  `do ... end` or `{ ... }`
#     - multi-line hash literals: `{ ... }`
#     - multi-line array literals: `[ ... ]`

const EMPTY_STRING = ""
const COMMENT_CHAR = "#"

const HEREDOC_START_PATTERN = '\v\<\<%(-|\~)?' .. "[\"'`]?" .. '\zs[0-9a-zA-Z_]+'
const FOLD_START_PATTERN =
  '\v^%(class|module|def|if|unless|when|else|elsif|begin|rescue|ensure)>|'
    .. '^%(public|protected|private)$|'
    .. '%(<do|\{)%(\s*\|.+\|)?$|'
    .. '\[$'
const FOLD_END_PATTERN = '\v^%(end>|\}|\])'
const ONE_LINER_PATTERN = '\v<end>'

export def Expr(lnum: number): string
  const line = getline(lnum)->trim()

  if IsHeredocEnd(line)
    const indent = b:ruby_fold_heredoc_indent
    unlet! b:ruby_fold_heredoc_key
    unlet! b:ruby_fold_heredoc_indent
    return "<" .. string(indent)
  elseif IsInHeredoc(line)
    return "="
  elseif IsNoContent(line)
    return "="
  elseif IsFoldEnd(line)
    return "<" .. string(IndentLevel(lnum))
  elseif IsHeredocStart(line)
    b:ruby_fold_heredoc_key    = matchstr(line, HEREDOC_START_PATTERN)
    b:ruby_fold_heredoc_indent = IndentLevel(lnum)
    return ">" .. string(b:ruby_fold_heredoc_indent)
  elseif IsFoldStart(line)
    return ">" .. string(IndentLevel(lnum))
  else
    # Return stringified number because Vim9 script currenty doesn't support `string | number` return type
    return string(IndentLevel(lnum) - 1)
  endif
enddef

def IndentLevel(lnum: number): number
  return indent(lnum) / &shiftwidth + 1
enddef

def IsNoContent(line: string): bool
  return line ==# EMPTY_STRING || kg8m#util#string#StartsWith(line, COMMENT_CHAR)
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
  return !!has_key(b:, "ruby_fold_heredoc_key") && line ==# b:ruby_fold_heredoc_key
enddef

# Call this only if `IsHeredocEnd()` returns `false`
def IsInHeredoc(line: string): bool
  return !!has_key(b:, "ruby_fold_heredoc_key")
enddef