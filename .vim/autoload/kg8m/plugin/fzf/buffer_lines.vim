vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

# Wrapper function to show preview around each line (fzf's `:BLines` doesn't show preview)
def kg8m#plugin#fzf#buffer_lines#run(query: string = ""): void
  const options = [
    "--preview", printf("$FZF_VIM_PATH/bin/preview.sh %s:{1}", expand("%")->shellescape()),
    "--preview-window", "down:50%:wrap:nohidden:+{1}-/2",
  ]

  kg8m#plugin#fzf#run(() => fzf#vim#buffer_lines(query, { options: options }))
enddef
