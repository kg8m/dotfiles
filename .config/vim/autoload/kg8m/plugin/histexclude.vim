vim9script

export def OnSource(): void
  g:histexclude = { ":": '\v^[:[:space:]]*%(\d+|b.|e|w?%[qa]?)!?\s*$' }

  # Disable because mappings like `q:` by vim-histexclude conflict with my mapping `q`
  g:histexclude_mappings = false
enddef

export def Run(): string
  kg8m#plugin#EnsureSourced("vim-histexclude")

  # https://github.com/itchyny/vim-histexclude/blob/69eb4467f261ed11852c36908c50fb351bafe103/plugin/histexclude.vim#L20
  return histexclude#update(":")
enddef
