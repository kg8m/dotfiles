vim9script

export def Configure(): void
  map <Leader>o <Plug>(openbrowser-open)

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(openbrowser-open)" },
    hook_source: () => OnSource(),
  })
enddef

def OnSource(): void
  # `main` server configs in `.ssh/config` is required
  g:openbrowser_browser_commands = [
    {
      name: "ssh",
      args: "ssh main -t 'open '\\''{uri}'\\'''",
    },
  ]
enddef
