vim9script

export def Configure(): void
  if !has_key(g:, "rails_path_additions")
    g:rails_path_additions = []
  endif

  if isdirectory("spec/support")
    g:rails_path_additions += [
      "spec/support",
    ]
  endif

  # Don't load lazily because some features don't work
  kg8m#plugin#Configure({
    lazy: false,
  })
enddef
