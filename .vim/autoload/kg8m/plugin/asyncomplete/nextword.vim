vim9script

def kg8m#plugin#asyncomplete#nextword#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_i:     true,
    on_start: true,
    depends:  ["async.vim", "asyncomplete.vim"],
    hook_post_source: () => s:on_post_source(),
  })

  if kg8m#plugin#register("prabirshrestha/async.vim")
    kg8m#plugin#configure({
      lazy: true,
    })
  endif
enddef

def s:on_post_source(): void
  # Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
  asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options({
    name: "nextword",
    allowlist: ["*"],
    args: ["-n", "10000"],
    completor: function("asyncomplete#sources#nextword#completor"),
    priority: 3,
  }))
enddef
