vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"

# Show preview in larger area (fzf's `:Helptags` doesn't)
export def Run(): void
  # https://github.com/junegunn/fzf.vim/blob/d5f1f8641b24c0fd5b10a299824362a2a1b20ae0/plugin/fzf.vim#L63
  final options = fzf#vim#with_preview({ placeholder: "--tag {2}:{3}:{4}" })
  options.options += ["--preview-window", "down:75%:wrap:nohidden"]

  fzf#vim#helptags(options)
enddef

plugin.EnsureSourced("fzf.vim")
