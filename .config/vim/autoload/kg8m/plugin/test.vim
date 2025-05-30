vim9script

import autoload "kg8m/util/filetypes/javascript.vim" as jsUtil
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

  if jsUtil.ShouldUseDeno()
    g:test#javascript#runner = "denotest"
  endif

  g:test#javascript#denotest#options = "--allow-all --no-check"
  g:test#go#gotest#options = "-race"
  g:test#ruby#rspec#executable = "rspec"
  g:test#ruby#bundle_exec = false

  doautocmd <nomodeline> User plugin:test:source
enddef

export def SaveAndRunFileTest(): void
  SaveIfModified()
  RunFileTest()
enddef

export def SaveAndRunNearestTest(): void
  SaveIfModified()
  RunNearestTest()
enddef

def SaveIfModified(): void
  if &modified
    write
  endif
enddef

def RunFileTest(): void
  TestFile
  doautocmd <nomodeline> User plugin:test:run
enddef

def RunNearestTest(): void
  TestNearest
  doautocmd <nomodeline> User plugin:test:run
enddef
