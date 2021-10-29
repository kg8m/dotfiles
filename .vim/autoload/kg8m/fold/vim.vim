vim9script

# Folding expression for Vim based on some keywords and markers.
#   - keywords: `function`, `if`, `endfunction`, `augroup foo`, and so on
#   - markers: `{{{ ... }}}`
#   - here-documents: `let foo =<< FOO ... FOO`

def s:set_comment_char(): void
  b:vim_fold_comment_char = getline(1) ==# "vim9script" ? "#" : '"'
enddef

augroup my_vimrc
  autocmd FileType vim s:set_comment_char()
augroup END

if &filetype ==# "vim" && !has_key(b:, "vim_fold_comment_char")
  s:set_comment_char()
endif

const EMPTY_STRING = ""

const HEREDOC_START_PATTERN = '\v\=\<\<\s+(trim\s+)?\zs\S+'

const START_KEYWORD_PATTERN = '\v^%(fu%[nction]|def|if|for)>|^aug%[roup]\s+(END)@!'
const END_KEYWORD_PATTERN   = '\v^%(endf%[unction]|enddef|endif|endfor|aug%[roup]\s+END)>'
const ONE_LINER_PATTERN     = '\v<%(endf%[unction]|enddef|endif|endfor|aug%[roup]\s+END)>'

const START_MARKER_PATTERN = '\v["#].*\{{3}'
const END_MARKER_PATTERN   = '\v["#].*\}{3}'

def kg8m#fold#vim#expr(lnum: number): string
  const line = getline(lnum)->trim()

  if s:is_heredoc_end(line)
    unlet! b:vim_fold_heredoc_key
    return "s1"
  elseif s:is_in_heredoc(line)
    return "="
  elseif s:is_no_content(line)
    if s:contains_start_marker(line)
      return "a1"
    elseif s:contains_end_marker(line)
      return "s1"
    else
      return "="
    endif
  elseif s:contains_end_keywords(line) || s:contains_end_marker(line)
    return "s1"
  elseif s:is_heredoc_start(line)
    b:vim_fold_heredoc_key = matchstr(line, HEREDOC_START_PATTERN)
    return "a1"
  elseif s:contains_start_keywords(line) || s:contains_start_marker(line)
    return "a1"
  else
    return "="
  endif
enddef

def s:is_no_content(line: string): bool
  return line ==# EMPTY_STRING || kg8m#util#string#starts_with(line, b:vim_fold_comment_char)
enddef

def s:contains_start_keywords(line: string): bool
  return !!(line =~# START_KEYWORD_PATTERN && line !~# ONE_LINER_PATTERN)
enddef

def s:contains_end_keywords(line: string): bool
  return !!(line =~# END_KEYWORD_PATTERN)
enddef

def s:contains_start_marker(line: string): bool
  return !!(line =~# START_MARKER_PATTERN && line !~# END_MARKER_PATTERN)
enddef

def s:contains_end_marker(line: string): bool
  return !!(line =~# END_MARKER_PATTERN && line !~# START_MARKER_PATTERN)
enddef

def s:is_heredoc_start(line: string): bool
  return !!(line =~# HEREDOC_START_PATTERN)
enddef

def s:is_heredoc_end(line: string): bool
  return !!has_key(b:, "vim_fold_heredoc_key") && line ==# b:vim_fold_heredoc_key
enddef

# Call this only if `s:is_heredoc_end()` returns `false`
def s:is_in_heredoc(line: string): bool
  return !!has_key(b:, "vim_fold_heredoc_key")
enddef
