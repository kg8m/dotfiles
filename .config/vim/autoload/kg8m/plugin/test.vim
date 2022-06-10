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

def VimuxStrategy(command: string): void
  # Just execute the command without echo it
  kg8m#plugin#vimux#RunCommand(command)
enddef

def OnSource(): void
  if kg8m#util#OnTmux()
    g:test#custom_strategies = get(g:, "test#custom_strategies", {})
    g:test#custom_strategies.vimux = VimuxStrategy
    g:test#strategy = "vimux"
  endif

  g:test#preserve_screen = true

  g:test#go#gotest#options = "-race"
  g:test#ruby#bundle_exec = false
enddef
