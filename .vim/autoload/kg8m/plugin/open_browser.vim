vim9script

def kg8m#plugin#open_browser#configure(): void
  map <Leader>o <Plug>(openbrowser-open)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: { nx: "<Plug>(openbrowser-open)" },
    hook_source: () => s:on_source(),
  })
enddef

def s:on_source(): void
  # `main` server configs in `.ssh/config` is required
  g:openbrowser_browser_commands = [
    {
      name: "ssh",
      args: "ssh main -t 'open '\\''{uri}'\\'''",
    },
  ]
enddef
