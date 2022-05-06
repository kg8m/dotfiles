vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# Show preview of files with my `preview` command (fzf's `:Files` doesn't use mine)
export def Run(): void
  const options = {
    options: [
      "--preview", "preview {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  # https://github.com/junegunn/fzf.vim/blob/d5f1f8641b24c0fd5b10a299824362a2a1b20ae0/plugin/fzf.vim#L48
  kg8m#plugin#fzf#Run(() => fzf#vim#files("", options))
enddef
