vim9script

def kg8m#plugin#asyncomplete#tabnine#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_i:     true,
    on_start: true,
    depends:  "asyncomplete.vim",
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:on_post_source(): void
  asyncomplete#register_source(asyncomplete#sources#tabnine#get_source_options({
    name: "tabnine",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#tabnine#completor"),
    priority: 0,
  }))
enddef
