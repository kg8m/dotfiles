vim9script

import autoload "kg8m/util.vim"
import autoload "kg8m/util/terminal.vim" as terminalUtil

augroup vimrc-plugin-test
  autocmd!
  autocmd User plugin:test:source ++once :
augroup END

export def OnSource(): void
  if util.OnTmux()
    g:test#custom_strategies = get(g:, "test#custom_strategies", {})
    g:test#custom_strategies.terminal = terminalUtil.ExecuteCommand
    g:test#strategy = "terminal"
  endif

  g:test#preserve_screen = true

  g:test#javascript#denotest#options = "--allow-all --no-check"
  g:test#go#gotest#options = "-race"
  g:test#ruby#bundle_exec = false
  g:test#ruby#rspec#options = "--no-profile"

  doautocmd <nomodeline> User plugin:test:source
enddef
