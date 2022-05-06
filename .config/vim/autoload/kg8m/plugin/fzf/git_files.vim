vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# Show better preview of dirty files (fzf's `:GFiles?` doesn't)
export def Run(): void
  const options = {
    options: [
      "--preview", "git diff-or-cat {2}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#vim#gitfiles("?", options))
enddef
