function kg8m#plugin#test#configure() abort  " {{{
  nnoremap <Leader>T :write<Cr>:TestFile<Cr>
  nnoremap <Leader>t :write<Cr>:TestNearest<Cr>

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: ["TestFile", "TestNearest"],
  \   hook_source: function("s:on_source"),
  \ })
endfunction  " }}}

function s:vimux_strategy(command) abort  " {{{
  " Just execute the command without echo it
  call VimuxRunCommand(a:command)
endfunction  " }}}

function s:on_source() abort  " {{{
  if kg8m#util#on_tmux()
    let g:test#custom_strategies = get(g:, "test#custom_strategies", {})
    let g:test#custom_strategies.vimux = function("s:vimux_strategy")
    let g:test#strategy = "vimux"
  endif

  let g:test#preserve_screen = v:true

  let g:test#go#gotest#options = "-race"
  let g:test#ruby#bundle_exec = v:false
endfunction  " }}}
