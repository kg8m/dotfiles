vim9script

def kg8m#ruby#restart_rubocop_daemon(): void  # {{{
  if executable("rubocop-daemon")
    job_start(["rubocop-daemon", "restart"])
  endif
enddef  # }}}
