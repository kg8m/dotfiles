vim9script

# Folding expression for Vim based on some keywords and markers.
#   - keywords: `function`, `if`, `endfunction`, `augroup foo`, and so on
#   - markers: {{{ ... }}}

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

const START_KEYWORD_PATTERN = '\v^%(function|def|if|for)>|^augroup\s+(END)@!'
const END_KEYWORD_PATTERN   = '\v^%(endfunction|enddef|endif|endfor|augroup\s+END)>'
const ONE_LINER_PATTERN     = '\v<%(endfunction|enddef|endif|endfor|augroup\s+END)>'

const START_MARKER_PATTERN = '\v["#].*\{\{\{'
const END_MARKER_PATTERN   = '\v["#].*\}\}\}'

def kg8m#fold#vim#expr(lnum: number): string
  const line = getline(lnum)->trim()

  if s:is_no_content(line)
    if s:contains_start_marker(line)
      return "a1"
    elseif s:contains_end_marker(line)
      return "s1"
    else
      return "="
    endif
  elseif s:contains_end_keywords(line) || s:contains_end_marker(line)
    return "s1"
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
