vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Show preview of dirty files (Fzf's `:GFiles?` doesn't show preview)
def kg8m#plugin#fzf#git_files#run(): void
  fzf#vim#gitfiles("?", {
    options: [
      "--preview", "git diff-or-cat {2}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  })
enddef
