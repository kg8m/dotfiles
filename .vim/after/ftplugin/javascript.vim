" Syntax-based folding is too heavy when editing a large file.
" This `JavaScriptFold` is based on `{ ... }` or `[ ... ]` literals and each line indentation.

setlocal foldmethod=expr foldexpr=JavaScriptFold(v:lnum)

if exists("JavaScriptFold")
  finish
endif

let s:fold_start = '\v(\{|\[)\s*$'
let s:fold_end   = '\v^\s*(\}|\])'

function! JavaScriptFold(lnum)
  let l:line = getline(a:lnum)

  if l:line =~ s:fold_start
    return ">"..s:IndentLevel(a:lnum)
  elseif l:line =~ s:fold_end
    return "<"..s:IndentLevel(a:lnum)
  else
    return "="
  endif
endfunction

function! s:IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth + 1
endfunction
