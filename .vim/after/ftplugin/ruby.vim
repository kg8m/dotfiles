" Syntax-based folding gets broken depending on syntax-brokenness.
" This `RubyFold` is based on keywords and each line indent.
"   - keywords: `class`, `def`, `end`, and so on
"   - other supports:
"     - here-documents
"     - blocks (do-end or `{ .... }`)
"     - multi-line hash literals
"     - multi-line array literals

setlocal foldmethod=expr foldexpr=RubyFold(v:lnum)

if exists('RubyFold')
  finish
endif

let s:ignore = '^\s*\%($\|#\)'
let s:heredoc_start = '<<\%(-\|\~\)\?' . "[\"'`]\\?" . '\zs[0-9a-zA-Z_]\+'
let s:fold_start = '\C^\s*\%(class\|module\|def\|if\|unless\|when\|else\|elsif\|begin\|rescue\|ensure\)\>\|' .
                 \ '\<\%(public\|protected\|private\)\s*$\|' .
                 \ '\<do\%(\s*|.*|\)\?\s*$\|' .
                 \ '{\%(\s*|.*|\)\?\s*$\|' .
                 \ '[\s*$'
let s:fold_end   = '\C^\s*\%(end\|}\|]\)\s*$'
let s:finish_with_end = '\C\%(\<end\|}\|]\)\s*$'

function! RubyFold(lnum)
  let l:line = getline(a:lnum)

  if s:IsHeredocEnd(l:line)
    unlet b:heredoc_key
    return '<' . s:IndentLevel(a:lnum)
  elseif s:IsPrevLineInHeredoc()
    return '='
  elseif l:line =~ s:ignore
    return '='
  elseif l:line =~ s:fold_end
    return '<' . s:IndentLevel(a:lnum)
  elseif l:line =~ s:heredoc_start
    let b:heredoc_key = matchstr(l:line, s:heredoc_start, 0)
    return '>' . s:IndentLevel(a:lnum)
  elseif l:line =~ s:fold_start && l:line !~ s:finish_with_end
    return '>' . s:IndentLevel(a:lnum)
  else
    return s:IndentLevel(a:lnum) - 1
  endif
endfunction

function! s:IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth + 1
endfunction

function! s:IsPrevLineInHeredoc()
  return exists('b:heredoc_key')
endfunction

function! s:IsHeredocEnd(line)
  return s:IsPrevLineInHeredoc() && a:line =~ '\C^\s*' . b:heredoc_key . '\s*$'
endfunction
