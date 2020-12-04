vim9script

def kg8m#javascript#restart_eslint_d(): void  # {{{
  if executable("eslint_d")
    job_start(["eslint_d", "restart"])
  endif
enddef  # }}}
