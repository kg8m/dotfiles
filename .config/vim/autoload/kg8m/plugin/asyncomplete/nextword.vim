vim9script

# TODO: Remove this and use mocword.
export def OnPostSource(): void
  # Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
  asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options({
    name: "nextword",
    allowlist: ["*"],
    args: ["-n", "10"],
    completor: function("asyncomplete#sources#nextword#completor"),
    priority: 5,
  }))
enddef
