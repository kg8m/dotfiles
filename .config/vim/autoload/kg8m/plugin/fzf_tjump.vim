vim9script

export def OnSource(): void
  g:fzf_tjump_preview_options     = "down:75%:wrap:nohidden:+{3}-/2"
  g:fzf_tjump_path_to_preview_bin = "preview"
enddef

export def Run(): void
  kg8m#plugin#EnsureSourced("vim-fzf-tjump")
  kg8m#plugin#fzf#Run(() => fzf_tjump#jump())
enddef
