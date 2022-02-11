vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# Wrapper function to show preview around each line (fzf's `:BLines` doesn't show preview)
export def Run(query: string = ""): void
  const options = [
    "--preview", printf("preview %s:{1}", expand("%")->shellescape()),
    "--preview-window", "down:50%:wrap:nohidden:+{1}-/2",
  ]

  kg8m#plugin#fzf#Run(() => fzf#vim#buffer_lines(query, { options: options }))
enddef
