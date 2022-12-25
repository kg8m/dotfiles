vim9script

export def OnSource(): void
  if kg8m#util#OnTmux()
    g:test#custom_strategies = get(g:, "test#custom_strategies", {})
    g:test#custom_strategies.terminal = kg8m#util#terminal#ExecuteCommand
    g:test#strategy = "terminal"
  endif

  g:test#preserve_screen = true

  g:test#javascript#denotest#options = "--allow-all --no-check"
  g:test#go#gotest#options = "-race"
  g:test#ruby#bundle_exec = false
  g:test#ruby#rspec#options = "--no-profile"
enddef
