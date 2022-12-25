vim9script

export def OnPostSource(): void
  asyncomplete#register_source(asyncomplete#sources#tabnine#get_source_options({
    name: "tabnine",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#tabnine#completor"),
    priority: 1,
  }))
enddef
