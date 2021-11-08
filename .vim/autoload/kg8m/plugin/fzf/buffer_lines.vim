vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Wrapper function to show preview around each line (Fzf's `:BLines` doesn't show preview)
def kg8m#plugin#fzf#buffer_lines#run(query: string = ""): void
  const options = [
    "--preview", printf("$FZF_VIM_PATH/bin/preview.sh %s:{1}", expand("%")->shellescape()),
    "--preview-window", "down:50%:wrap:nohidden:+{1}-/2",
  ]

  fzf#vim#buffer_lines(query, { options: options })
enddef
