vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"

# Show preview of marks (fzf's `:Marks` doesn't show preview)
export def Run(): void
  const options = {
    options: [
      # 1      2      3     4
      # {mark} {line} {col} {filepath or content}
      "--preview", "preview {4..}:{2} 2>/dev/null || echo {}",
      "--preview-window", "down:75%:wrap:nohidden:+{2}-/2",
    ],
  }

  fzf#vim#marks(options)
enddef

plugin.EnsureSourced("fzf.vim")
