vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# Show preview of files with my `preview` command and use my prompt (fzf's `:Files` doesn't use mine)
export def Run(): void
  const options = {
    options: [
      "--prompt", $"{GetCwd()}> ",
      "--preview", "preview {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  # https://github.com/junegunn/fzf.vim/blob/d5f1f8641b24c0fd5b10a299824362a2a1b20ae0/plugin/fzf.vim#L48
  kg8m#plugin#fzf#Run(() => fzf#vim#files("", options))
enddef

def GetCwd(): string
  # Footer = the last slash and dirname
  const full_cwd      = getcwd()
  const dirname_width = fnamemodify(full_cwd, ":t")->strdisplaywidth()
  const max_width     = min([dirname_width + 10, 30])
  const footer_width  = dirname_width + 1

  return kg8m#util#string#Truncate(full_cwd, max_width, { footer_width: footer_width })
enddef
