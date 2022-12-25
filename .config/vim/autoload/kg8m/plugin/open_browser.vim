vim9script

export def OnSource(): void
  # `main` server configs in `.ssh/config` is required
  g:openbrowser_browser_commands = [
    {
      name: "ssh",
      args: "ssh main -t 'open '\\''{uri}'\\'''",
    },
  ]
enddef
