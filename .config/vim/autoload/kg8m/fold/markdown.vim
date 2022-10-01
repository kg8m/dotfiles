vim9script

# Folding for Markdown is sometimes too heavy.
# This folding expression is based on some symbols:
#   - headers
#   - fenced code blocks
#   - `<details><summary>Summary</summary> ... </details>`

const EMPTY_STRING = ""

const CODEBLOCK_START_PATTERN = '\v^\zs`{3,}\ze'

const DETAILS_START_PATTERN = '\v^\<details\>$'
const DETAILS_END_PATTERN   = '\v^\</details\>$'
const SUMMARY_END_PATTERN   = '\v\</summary\>'

const HASH_HEADER_PATTERN = '\v^\zs#{1,}\ze'
const EQUAL_H1_PATTERN    = '\v^\={3,}$'
const HYPHEN_H2_PATTERN   = '\v^-{3,}$'

export def Expr(): string
  const line = getline(v:lnum)->trim()

  if IsCodeblockEnd(line)
    unlet! b:markdown_fold_codeblock_backticks
    return "s1"
  elseif IsInCodeblock(line)
    return "="
  elseif IsNoContent(line)
    return "="
  elseif IsCodeblockStart(line)
    b:markdown_fold_codeblock_backticks = matchstr(line, CODEBLOCK_START_PATTERN)
    return "a1"
  elseif IsSummaryEnd(line)
    return "a1"
  elseif IsDetailsEnd(line)
    unlet! b:markdown_fold_details
    return "s1"
  elseif IsDetailsStart(line)
    b:markdown_fold_details = true
    return "="
  elseif IsHashHeader(line)
    const hashes = matchstr(line, HASH_HEADER_PATTERN)
    return ">" .. string(len(hashes))
  else
    const nextline = getline(v:lnum + 1)->trim()

    if IsEqualH1(nextline)
      return ">1"
    elseif IsHyphenH2(nextline)
      return ">2"
    else
      return "="
    endif
  endif
enddef

def IsNoContent(line: string): bool
  return line ==# EMPTY_STRING
enddef

def IsHashHeader(line: string): bool
  return !!(line =~# HASH_HEADER_PATTERN)
enddef

def IsEqualH1(line: string): bool
  return !!(line =~# EQUAL_H1_PATTERN)
enddef

def IsHyphenH2(line: string): bool
  return !!(line =~# HYPHEN_H2_PATTERN)
enddef

def IsCodeblockStart(line: string): bool
  return !has_key(b:, "markdown_fold_codeblock_backticks") && !!(line =~# CODEBLOCK_START_PATTERN)
enddef

def IsCodeblockEnd(line: string): bool
  return !!has_key(b:, "markdown_fold_codeblock_backticks") && line ==# b:markdown_fold_codeblock_backticks
enddef

# Call this only if `IsCodeblockEnd()` returns `false`
def IsInCodeblock(line: string): bool
  return !!has_key(b:, "markdown_fold_codeblock_backticks")
enddef

def IsDetailsStart(line: string): bool
  return !!(line =~# DETAILS_START_PATTERN)
enddef

def IsDetailsEnd(line: string): bool
  return !!has_key(b:, "markdown_fold_details") && !!(line =~# DETAILS_END_PATTERN)
enddef

def IsSummaryEnd(line: string): bool
  return !!has_key(b:, "markdown_fold_details") && !!(line =~# SUMMARY_END_PATTERN)
enddef
