function! kg8m#ruby#restart_rubocop_daemon() abort  " {{{
  if executable("rubocop-daemon")
    call job_start(["rubocop-daemon", "restart"])
  endif
endfunction  " }}}
