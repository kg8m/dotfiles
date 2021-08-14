vim9script

def kg8m#plugin#asyncomplete#file#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_i:     true,
    on_start: true,
    depends:  "asyncomplete.vim",
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:on_post_source(): void
  asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    name: "file",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#file#completor"),
    priority: 2,
  }))
enddef
