" Ignore some files, e.g., `.git/COMMIT_EDITMSG`, `.git/addp-hunk-edit.diff`, and so on (Fzf's `:History` doesn't ignore them)
function kg8m#plugin#fzf#history#run() abort  " {{{
  let options = #{
  \   source:  s:candidates(),
  \   options: [
  \     "--header-lines", empty(kg8m#plugin#fzf#current_filepath()) ? 0 : 1,
  \     "--prompt", "History> ",
  \     "--preview", "git cat {}",
  \     "--preview-window", "right:50%:wrap:nohidden",
  \   ],
  \ }

  call fzf#run(fzf#wrap("history-files", options))
endfunction  " }}}

" `buffers` are for files not included in `mr#mru#list()`, e.g.,
"   - renamed files by `:Rename`
"   - opened files by `vim foo bar baz`
function s:candidates() abort  " {{{
  let current  = [kg8m#plugin#fzf#current_filepath()]->filter("!empty(v:val)")
  let buffers  = s:buffers()
  let oldfiles = s:oldfiles()

  return kg8m#util#list_module().uniq(current + buffers + oldfiles)
endfunction  " }}}

function s:buffers() abort  " {{{
  return getbufinfo()
  \   ->sort("s:buffers_sorter")
  \   ->filter("!empty(v:val.name)")
  \   ->map("v:val.name->fnamemodify(kg8m#plugin#fzf#filepath_format())")
endfunction  " }}}

function s:buffers_sorter(lhs, rhs) abort  " {{{
  if a:lhs.lastused ==# a:rhs.lastused
    return a:lhs.name <# a:rhs.name ? 1 : -1
  else
    return a:lhs.lastused <# a:rhs.lastused ? 1 : -1
  endif
endfunction  " }}}

function s:oldfiles() abort  " {{{
  let filepaths = mr#mru#list()->copy()->filter("v:val->filereadable()")
  return filepaths->map("v:val->fnamemodify(kg8m#plugin#fzf#filepath_format())")
endfunction  " }}}
