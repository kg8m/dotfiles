vim9script

import autoload "kg8m/plugin/completion.vim"

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
    autocmd TextChangedI * completion.Refresh(300)
  augroup END
enddef
