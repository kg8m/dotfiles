vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

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

  kg8m#plugin#fzf#Run(() => fzf#vim#marks(options))
enddef
