vim9script

export def Setup(): void
  augroup vimrc-util-daemons
    autocmd!
    autocmd BufWritePost .eslintrc.*,package.json,tsconfig.json RestartEslintD()
    autocmd BufWritePost .rubocop.yml                           RestartRubocopServer()
    autocmd BufWritePost config/routes.rb,config/routes/*.rb    UpdateRoutingDependencies()
  augroup END
enddef

export def RestartEslintD(): void
  if IsEslintDAvailable()
    job_start(["eslint_d", "restart"])
  endif
enddef

export def RestartRubocopServer(): void
  if IsRubocopServerAvailable()
    job_start(["rubocop", "--restart-server"])
  elseif IsRubocopDaemonAvailable()
    job_start(["rubocop-daemon", "restart"])
  endif
enddef

def IsEslintDAvailable(): bool
  return !!executable("eslint_d")
enddef

def IsRubocopServerAvailable(): bool
  return !!executable("rubocop") && !!(system("rubocop --server-status") =~# '^RuboCop server')
enddef

def IsRubocopDaemonAvailable(): bool
  return !!executable("rubocop-daemon")
enddef

def UpdateRoutingDependencies(): void
  if executable("annotate")
    job_start(["rails", "annotate_routes"])
  endif

  if isdirectory("sig/rbs_rails")
    job_start(["rails", "rbs_rails:generate_rbs_for_path_helpers"])
  endif
enddef
