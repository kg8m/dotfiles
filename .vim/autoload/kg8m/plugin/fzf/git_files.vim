" Show preview of dirty files (Fzf's `:GFiles?` doesn't show preview)
function kg8m#plugin#fzf#git_files#run() abort  " {{{
  call fzf#vim#gitfiles("?", #{
  \   options: [
  \     "--preview", "git diff-or-cat {2}",
  \     "--preview-window", "right:50%:wrap:nohidden",
  \   ],
  \ })
endfunction  " }}}
