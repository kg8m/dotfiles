vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

# Show preview of dirty files (Fzf's `:GFiles?` doesn't show preview)
def kg8m#plugin#fzf#git_files#run(): void
  fzf#vim#gitfiles("?", {
    options: [
      "--preview", "git diff-or-cat {2}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  })
enddef
