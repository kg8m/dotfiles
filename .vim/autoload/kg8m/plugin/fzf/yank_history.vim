" https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
" Also see configs for yankround.vim
function kg8m#plugin#fzf#yank_history#run() abort  " {{{
  let options = #{
  \   source:  s:candidates(),
  \   sink:    function("kg8m#plugin#yankround#fzf#handler"),
  \   options: [
  \     "--no-multi",
  \     "--nth", "2..",
  \     "--prompt", "Yank> ",
  \     "--tabstop", "1",
  \     "--preview", kg8m#plugin#yankround#fzf#preview_command(),
  \     "--preview-window", "down:5:wrap:nohidden",
  \   ],
  \ }

  call fzf#run(fzf#wrap("yank-history", options))
endfunction  " }}}

function s:candidates() abort  " {{{
  return kg8m#plugin#yankround#fzf#list()
endfunction  " }}}
