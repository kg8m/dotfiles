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
  asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
    name: "tags",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#tags#completor"),
    priority: 3,
  }))

  augroup vimrc-plugin-asyncomplete-tags
    autocmd!

    # Forcefully refresh completion candidates after texts change because completion candidates are not refreshed after
    # updating tags file.
    autocmd TextChangedI * kg8m#plugin#completion#Refresh(300)
  augroup END
enddef
