function kg8m#plugin#linediff#configure() abort  " {{{
  let g:linediff_second_buffer_command = "rightbelow vertical new"

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: "Linediff",
  \ })
endfunction  " }}}
