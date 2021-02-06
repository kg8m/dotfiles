vim9script

# Syntax-based folding gets broken depending on syntax-brokenness.
# This `kg8m#fold#ruby#expr` is based on keywords and each line indent.
#   - keywords: `class`, `def`, `end`, and so on
#   - other supports:
#     - here-documents
#     - blocks (do-end or `{ ... }`)
#     - multi-line hash literals
#     - multi-line array literals

const EMPTY_STRING = ""
const COMMENT_CHAR = "#"

const HEREDOC_START_PATTERN = '\v\<\<%(-|\~)?' .. "[\"'`]?" .. '\zs[0-9a-zA-Z_]+'
const FOLD_START_PATTERN =
  '\v^%(class|module|def|if|unless|when|else|elsif|begin|rescue|ensure)>|'
    .. '^%(public|protected|private)$|'
    .. '%(<do|\{)%(\s*\|.+\|)?$|'
    .. '\[$'
const FOLD_END_PATTERN = '\v^%(end|\}|\])$'
const FINISH_WITH_END_PATTERN = '\v%(<end|\}|\])$'

def kg8m#fold#ruby#expr(lnum: number): string
  const line = getline(lnum)->trim()

  if s:is_no_content(line)
    return "="
  elseif s:is_heredoc_end(line)
    unlet! b:ruby_fold_heredoc_key
    return "<" .. string(s:indent_level(lnum))
  elseif s:is_prev_line_in_heredoc()
    return "="
  elseif s:is_fold_end(line)
    return "<" .. string(s:indent_level(lnum))
  elseif s:is_heredoc_start(line)
    b:ruby_fold_heredoc_key = matchstr(line, HEREDOC_START_PATTERN)
    return ">" .. string(s:indent_level(lnum))
  elseif s:is_fold_start(line)
    return ">" .. string(s:indent_level(lnum))
  else
    # Return stringified number because Vim9 script currenty doesn't support `string | number` return type
    return string(s:indent_level(lnum) - 1)
  endif
enddef

def s:indent_level(lnum: number): number
  return indent(lnum) / &shiftwidth + 1
enddef

def s:is_no_content(line: string): bool
  return line ==# EMPTY_STRING || kg8m#util#string#starts_with(line, COMMENT_CHAR)
enddef

def s:is_fold_start(line: string): bool
  return !!(line =~# FOLD_START_PATTERN && line !~# FINISH_WITH_END_PATTERN)
enddef

def s:is_fold_end(line: string): bool
  return !!(line =~# FOLD_END_PATTERN)
enddef

def s:is_heredoc_start(line: string): bool
  return !!(line =~# HEREDOC_START_PATTERN)
enddef

def s:is_prev_line_in_heredoc(): bool
  return !!has_key(b:, "ruby_fold_heredoc_key")
enddef

def s:is_heredoc_end(line: string): bool
  return s:is_prev_line_in_heredoc() && line ==# b:ruby_fold_heredoc_key
enddef
