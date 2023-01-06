vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"

# Wrapper function to show preview around each line (fzf's `:BLines` doesn't)
export def Run(query: string = ""): void
  const options = [
    "--preview", printf("preview %s:{1}", expand("%")->shellescape()),
    "--preview-window", "down:50%:wrap:nohidden:+{1}-/2",
  ]

  fzf.Run(() => fzf#vim#buffer_lines(query, { options: options }))
enddef

plugin.EnsureSourced("fzf.vim")
