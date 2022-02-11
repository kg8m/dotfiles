vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
# Also see configs for yankround.vim

export def Run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  Candidates(),
    sink:    function("kg8m#plugin#yankround#fzf#Handler"),
    options: [
      "--no-multi",
      "--nth", "2..",
      "--prompt", "Yank> ",
      "--tabstop", "1",
      "--preview", kg8m#plugin#yankround#fzf#PreviewCommand(),
      "--preview-window", "down:10:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("yank-history", options)))
enddef

def Candidates(): list<string>
  return kg8m#plugin#yankround#fzf#List()
enddef
