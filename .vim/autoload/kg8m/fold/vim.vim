vim9script

# Folding expression for Vim based on some keywords and markers.
#   - keywords: `function`, `if`, `endfunction`, `augroup foo`, and so on
#   - markers: `{{{ ... }}}`
#   - here-documents: `let foo =<< FOO ... FOO`

def SetCommentChar(): void
  b:vim_fold_comment_char = getline(1) ==# "vim9script" ? "#" : '"'
enddef

augroup vimrc-fold-vim
  autocmd!
  autocmd FileType vim SetCommentChar()
augroup END

if &filetype ==# "vim" && !has_key(b:, "vim_fold_comment_char")
  SetCommentChar()
endif

const EMPTY_STRING = ""

const HEREDOC_START_PATTERN = '\v\=\<\<\s+(trim\s+)?\zs\S+'

const START_KEYWORD_PATTERN = '\v^%(fu%[nction]|%(export\s+)?def|if|for)>|^aug%[roup]\s+(END)@!'
const END_KEYWORD_PATTERN   = '\v^%(endf%[unction]|enddef|endif|endfor|aug%[roup]\s+END)>'
const ONE_LINER_PATTERN     = '\v<%(endf%[unction]|enddef|endif|endfor|aug%[roup]\s+END)>'

const START_MARKER_PATTERN = '\v["#].*\{{3}'
const END_MARKER_PATTERN   = '\v["#].*\}{3}'

export def Expr(lnum: number): string
  const line = getline(lnum)->trim()

  if IsHeredocEnd(line)
    unlet! b:vim_fold_heredoc_key
    return "s1"
  elseif IsInHeredoc(line)
    return "="
  elseif IsNoContent(line)
    if ContainsStartMarker(line)
      return "a1"
    elseif ContainsEndMarker(line)
      return "s1"
    else
      return "="
    endif
  elseif ContainsEndKeywords(line) || ContainsEndMarker(line)
    return "s1"
  elseif IsHeredocStart(line)
    b:vim_fold_heredoc_key = matchstr(line, HEREDOC_START_PATTERN)
    return "a1"
  elseif ContainsStartKeywords(line) || ContainsStartMarker(line)
    return "a1"
  else
    return "="
  endif
enddef

def IsNoContent(line: string): bool
  return line ==# EMPTY_STRING || kg8m#util#string#StartsWith(line, b:vim_fold_comment_char)
enddef

def ContainsStartKeywords(line: string): bool
  return !!(line =~# START_KEYWORD_PATTERN && line !~# ONE_LINER_PATTERN)
enddef

def ContainsEndKeywords(line: string): bool
  return !!(line =~# END_KEYWORD_PATTERN)
enddef

def ContainsStartMarker(line: string): bool
  return !!(line =~# START_MARKER_PATTERN && line !~# END_MARKER_PATTERN)
enddef

def ContainsEndMarker(line: string): bool
  return !!(line =~# END_MARKER_PATTERN && line !~# START_MARKER_PATTERN)
enddef

def IsHeredocStart(line: string): bool
  return !!(line =~# HEREDOC_START_PATTERN)
enddef

def IsHeredocEnd(line: string): bool
  return !!has_key(b:, "vim_fold_heredoc_key") && line ==# b:vim_fold_heredoc_key
enddef

# Call this only if `IsHeredocEnd()` returns `false`
def IsInHeredoc(line: string): bool
  return !!has_key(b:, "vim_fold_heredoc_key")
enddef
