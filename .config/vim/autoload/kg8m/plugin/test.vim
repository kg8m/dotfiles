vim9script

export def Configure(): void
  nnoremap <Leader>T :write<CR>:TestFile<CR>
  nnoremap <Leader>t :write<CR>:TestNearest<CR>

  kg8m#plugin#Configure({
    lazy:   true,
    on_cmd: ["TestFile", "TestNearest"],
    hook_source: () => OnSource(),
  })
enddef

def OnSource(): void
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
