vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["asyncomplete.vim"],
    hook_post_source: () => OnPostSource(),
  })
enddef

def OnPostSource(): void
  # Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
  asyncomplete#register_source(asyncomplete#sources#mocword#get_source_options({
    name: "mocword",
    allowlist: ["*"],
    args: ["--limit", "100"],
    completor: function("asyncomplete#sources#mocword#completor"),
    priority: 4,
  }))
enddef
