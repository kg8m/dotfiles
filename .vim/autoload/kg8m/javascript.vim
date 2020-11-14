" Syntax-based folding is too heavy when editing a large file.
" This `kg8m#javascript#fold` is based on `{ ... }` or `[ ... ]` literals and each line indentation.

let s:fold_start = '\v(\{|\[)\s*$'
let s:fold_end   = '\v^\s*(\}|\])'

function! kg8m#javascript#fold(lnum) abort  " {{{
  let l:line = getline(a:lnum)

  if l:line =~ s:fold_start
    return ">"..s:IndentLevel(a:lnum)
  elseif l:line =~ s:fold_end
    return "<"..s:IndentLevel(a:lnum)
  else
    return "="
  endif
endfunction  " }}}

function! kg8m#javascript#restart_eslint_d() abort  " {{{
  if executable("eslint_d")
    call job_start(["eslint_d", "restart"])
  endif
endfunction  " }}}

function! s:IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth + 1
endfunction
