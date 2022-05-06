vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  "asyncomplete.vim",
    hook_post_source: () => OnPostSource(),
  })
enddef

def OnPostSource(): void
  asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
    name: "neosnippet",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#neosnippet#completor"),
    priority: 1,
  }))
enddef
