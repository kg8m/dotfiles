vim9script

export def OnPostSource(): void
  asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    name: "file",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#file#completor"),
    priority: 1,
  }))
enddef
