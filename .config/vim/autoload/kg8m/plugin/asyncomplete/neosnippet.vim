vim9script

export def OnPostSource(): void
  asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
    name: "neosnippet",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#neosnippet#completor"),
    priority: 1,
  }))
enddef
