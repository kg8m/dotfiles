vim9script

export def Setup(): void
  augroup vimrc-util-daemons
    autocmd!
    autocmd BufWritePost .eslintrc.*,package.json,tsconfig.json RestartEslintD()
    autocmd BufWritePost .rubocop.yml                           RestartRubocopDaemon()
  augroup END
enddef

export def RestartEslintD(): void
  if executable("eslint_d")
    job_start(["eslint_d", "restart"])
  endif
enddef

export def RestartRubocopDaemon(): void
  if executable("rubocop-daemon")
    job_start(["rubocop-daemon", "restart"])
  endif
enddef
