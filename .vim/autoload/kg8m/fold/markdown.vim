vim9script

# Folding for Markdown is sometimes too heavy.
# This folding expression is based on some symbols:
#   - headers
#   - fenced code blocks

const EMPTY_STRING = ""

const CODEBLOCK_START_PATTERN = '\v^\zs`{3,}\ze'

const HASH_HEADER_PATTERN = '\v^\zs#{1,}\ze'
const EQUAL_H1_PATTERN    = '\v^\={3,}$'
const HYPHEN_H2_PATTERN   = '\v^-{3,}$'

def kg8m#fold#markdown#expr(lnum: number): string
  const line = getline(lnum)->trim()

  if s:is_codeblock_end(line)
    unlet! b:markdown_fold_codeblock_backticks
    return "s1"
  elseif s:is_in_codeblock(line)
    return "="
  elseif s:is_no_content(line)
    return "="
  elseif s:is_codeblock_start(line)
    b:markdown_fold_codeblock_backticks = matchstr(line, CODEBLOCK_START_PATTERN)
    return "a1"
  elseif s:is_hash_header(line)
    const hashes = matchstr(line, HASH_HEADER_PATTERN)
    return ">" .. string(len(hashes))
  else
    const nextline = getline(lnum + 1)->trim()

    if s:is_equal_h1(nextline)
      return ">1"
    elseif s:is_hyphen_h2(nextline)
      return ">2"
    else
      return "="
    endif
  endif
enddef

def s:is_no_content(line: string): bool
  return line ==# EMPTY_STRING
enddef

def s:is_hash_header(line: string): bool
  return !!(line =~# HASH_HEADER_PATTERN)
enddef

def s:is_equal_h1(line: string): bool
  return !!(line =~# EQUAL_H1_PATTERN)
enddef

def s:is_hyphen_h2(line: string): bool
  return !!(line =~# HYPHEN_H2_PATTERN)
enddef

def s:is_codeblock_start(line: string): bool
  return !has_key(b:, "markdown_fold_codeblock_backticks") && !!(line =~# CODEBLOCK_START_PATTERN)
enddef

def s:is_codeblock_end(line: string): bool
  return !!has_key(b:, "markdown_fold_codeblock_backticks") && line ==# b:markdown_fold_codeblock_backticks
enddef

# Call this only if `s:is_codeblock_end()` returns `false`
def s:is_in_codeblock(line: string): bool
  return !!has_key(b:, "markdown_fold_codeblock_backticks")
enddef
