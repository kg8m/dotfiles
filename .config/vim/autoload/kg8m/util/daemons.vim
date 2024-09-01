vim9script

import autoload "kg8m/plugin/lsp/servers.vim" as lspServers

export def Setup(): void
  augroup vimrc-util-daemons
    autocmd!
    autocmd BufWritePost .eslintrc.*,package.json,tsconfig.json  RestartEslintD()
    autocmd BufWritePost .rubocop.yml                            RestartRubocopDaemon()
    autocmd BufWritePost */config/routes.rb,*/config/routes/*.rb UpdateRoutingDependencies()
  augroup END
enddef

export def RestartEslintD(): void
  if IsEslintDAvailable()
    JobStart(["eslint_d", "restart"])
  endif
enddef

export def RestartRubocopDaemon(): void
  if IsRubocopLspAvailable()
    LspStopServer rubocop
  elseif IsRubocopDaemonAvailable()
    JobStart(["rubocop-daemon", "restart"])
  endif
enddef

def IsEslintDAvailable(): bool
  return !!executable("eslint_d")
enddef

def IsRubocopLspAvailable(): bool
  return lspServers.IsAvailable("rubocop")
enddef

def IsRubocopDaemonAvailable(): bool
  return !!executable("rubocop-daemon")
enddef

def UpdateRoutingDependencies(): void
  if executable("annotate")
    JobStart(["rails", "annotate_routes"])
  endif

  if isdirectory("sig/rbs_rails")
    JobStart(["rails", "rbs_rails:generate_rbs_for_path_helpers"])
  endif

  # Recache routes.
  # cf. .config/zsh/bin/rails-routes
  JobStart(["rails-routes"])
enddef

def JobStart(command: list<string>): void
  # Specify a noop `close_cb` callback because sometimes the job could be killed without it.
  job_start(command, { close_cb: (_) => "noop" })
enddef
