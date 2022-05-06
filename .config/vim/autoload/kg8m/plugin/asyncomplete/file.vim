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
  asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    name: "file",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#file#completor"),
    priority: 2,
  }))
enddef
