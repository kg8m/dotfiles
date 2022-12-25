vim9script

export def OnPostSource(): void
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
