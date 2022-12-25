vim9script

export def OnPostSource(): void
  # Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
  asyncomplete#register_source(asyncomplete#sources#mocword#get_source_options({
    name: "mocword",
    allowlist: ["*"],
    args: ["--limit", "10"],
    completor: function("asyncomplete#sources#mocword#completor"),
    priority: 4,
  }))
enddef
