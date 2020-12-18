vim9script

def kg8m#plugin#linediff#configure(): void  # {{{
  g:linediff_second_buffer_command = "rightbelow vertical new"

  kg8m#plugin#configure({
    lazy:   v:true,
    on_cmd: "Linediff",
  })
enddef  # }}}
