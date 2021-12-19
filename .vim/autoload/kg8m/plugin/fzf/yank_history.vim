vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

# https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
# Also see configs for yankround.vim

def kg8m#plugin#fzf#yank_history#run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  s:candidates(),
    sink:    function("kg8m#plugin#yankround#fzf#handler"),
    options: [
      "--no-multi",
      "--nth", "2..",
      "--prompt", "Yank> ",
      "--tabstop", "1",
      "--preview", kg8m#plugin#yankround#fzf#preview_command(),
      "--preview-window", "down:10:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("yank-history", options)))
enddef

def s:candidates(): list<string>
  return kg8m#plugin#yankround#fzf#list()
enddef
