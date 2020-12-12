" Sort buffers in dictionary order (Fzf's `:Buffers` doesn't sort them)
function kg8m#plugin#fzf#buffers#run() abort  " {{{
  let options = #{
  \   source:  s:candidates(),
  \   options: [
  \     "--header-lines", empty(kg8m#plugin#fzf#current_filepath()) ? 0 : 1,
  \     "--prompt", "Buffers> ",
  \     "--preview", "git cat {}",
  \     "--preview-window", "right:50%:wrap:nohidden",
  \   ],
  \ }

  call fzf#run(fzf#wrap("buffer-files", options))
endfunction  " }}}

function s:candidates() abort  " {{{
  let current = [kg8m#plugin#fzf#current_filepath()]->filter("!empty(v:val)")
  let buffers = s:list()

  return kg8m#util#list_module().uniq(current + buffers)
endfunction  " }}}

function s:list() abort  " {{{
  return getbufinfo(#{ buflisted: v:true })
  \   ->filter("!empty(v:val.name)")
  \   ->map("v:val.name->fnamemodify(kg8m#plugin#fzf#filepath_format())")
  \   ->sort()
endfunction  " }}}
