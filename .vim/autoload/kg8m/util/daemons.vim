vim9script

def kg8m#util#daemons#setup(): void
  augroup vimrc-util-daemons
    autocmd!
    autocmd BufWritePost .eslintrc.*,package.json,tsconfig.json s:restart_eslint_d()
    autocmd BufWritePost .rubocop.yml                           s:restart_rubocop_daemon()
  augroup END
enddef

def s:restart_eslint_d(): void
  if executable("eslint_d")
    job_start(["eslint_d", "restart"])
  endif
enddef

def s:restart_rubocop_daemon(): void
  if executable("rubocop-daemon")
    job_start(["rubocop-daemon", "restart"])
  endif
enddef
