function kg8m#plugin#open_browser#configure() abort  " {{{
  map <Leader>o <Plug>(openbrowser-open)

  " `main` server configs in `.ssh/config` is required
  let g:openbrowser_browser_commands = [
  \   #{
  \     name: "ssh",
  \     args: "ssh main -t 'open '\\''{uri}'\\'''",
  \   }
  \ ]

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["nv", "<Plug>(openbrowser-open)"]],
  \ })
endfunction  " }}}
