vim9script

def kg8m#plugin#test#configure(): void
  nnoremap <Leader>T :write<CR>:TestFile<CR>
  nnoremap <Leader>t :write<CR>:TestNearest<CR>

  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: ["TestFile", "TestNearest"],
    hook_source: () => s:on_source(),
  })
enddef

def s:vimux_strategy(command: string): void
  # Just execute the command without echo it
  kg8m#plugin#vimux#run_command(command)
enddef

def s:on_source(): void
  if kg8m#util#on_tmux()
    g:test#custom_strategies = get(g:, "test#custom_strategies", {})
    g:test#custom_strategies.vimux = function("s:vimux_strategy")
    g:test#strategy = "vimux"
  endif

  g:test#preserve_screen = true

  g:test#go#gotest#options = "-race"
  g:test#ruby#bundle_exec = false
enddef
