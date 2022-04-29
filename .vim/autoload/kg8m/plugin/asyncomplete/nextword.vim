vim9script

# TODO: Remove this and use mocword.
export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  ["async.vim", "asyncomplete.vim"],
    hook_post_source: () => OnPostSource(),
  })

  # Skip because async.vim has been registered with mocword.
  # if kg8m#plugin#Register("prabirshrestha/async.vim")
  #   kg8m#plugin#Configure({
  #     lazy: true,
  #   })
  # endif
enddef

def OnPostSource(): void
  # Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
  asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options({
    name: "nextword",
    allowlist: ["*"],
    args: ["-n", "100"],
    completor: function("asyncomplete#sources#nextword#completor"),
    priority: 5,
  }))
enddef
