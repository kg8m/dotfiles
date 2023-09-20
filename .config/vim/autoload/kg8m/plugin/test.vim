vim9script

import autoload "kg8m/util.vim"
import autoload "kg8m/util/terminal.vim" as terminalUtil

augroup vimrc-plugin-test
  autocmd!
  autocmd User plugin:test:source ++once :
  autocmd User plugin:test:run           :
augroup END

export def OnSource(): void
  g:test#custom_strategies = get(g:, "test#custom_strategies", {})
  g:test#custom_strategies.tmux_or_vim_terminal = terminalUtil.ExecuteCommand
  g:test#strategy = "tmux_or_vim_terminal"

  g:test#preserve_screen = true

  g:test#javascript#denotest#options = "--allow-all --no-check"
  g:test#go#gotest#options = "-race"
  g:test#ruby#bundle_exec = false
  g:test#ruby#rspec#options = "--no-profile"

  doautocmd <nomodeline> User plugin:test:source
enddef

export def RunFileTest(): void
  TestFile
  doautocmd <nomodeline> User plugin:test:run
enddef

export def RunNearestTest(): void
  TestNearest
  doautocmd <nomodeline> User plugin:test:run
enddef
