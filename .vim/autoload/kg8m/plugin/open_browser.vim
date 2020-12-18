vim9script

def kg8m#plugin#open_browser#configure(): void  # {{{
  map <Leader>o <Plug>(openbrowser-open)

  # `main` server configs in `.ssh/config` is required
  g:openbrowser_browser_commands = [
    {
      name: "ssh",
      args: "ssh main -t 'open '\\''{uri}'\\'''",
    },
  ]

  kg8m#plugin#configure({
    lazy:   v:true,
    on_map: [["nv", "<Plug>(openbrowser-open)"]],
  })
enddef  # }}}
