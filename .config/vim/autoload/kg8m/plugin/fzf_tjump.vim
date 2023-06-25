vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"

export def OnSource(): void
  g:fzf_tjump_preview_options     = "down:75%:wrap:nohidden:+{3}-/2"
  g:fzf_tjump_path_to_preview_bin = "preview"
enddef

export def Run(): void
  fzf_tjump#jump()
enddef

plugin.EnsureSourced("vim-fzf-tjump")
