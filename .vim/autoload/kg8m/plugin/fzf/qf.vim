vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

const s:common_fzf_options = [
  "--preview", printf("git cat %s/{}.%s", shellescape(g:kg8m#util#qf#dirpath), kg8m#util#qf#extension),
  "--preview-window", "down:75%:wrap:nohidden",
]

def kg8m#plugin#fzf#qf#load(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#util#qf#list(),
    sink:    function("kg8m#util#qf#load"),
    options: s:common_fzf_options + [
      "--prompt", "Quickfix file to load> ",
      "--no-multi",
    ],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("load-quickfix", options)))
enddef

def kg8m#plugin#fzf#qf#edit(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#util#qf#list(),
    sink:    function("kg8m#util#qf#edit"),
    options: s:common_fzf_options + [
      "--prompt", "Quickfix file to edit> ",
      "--no-multi",
    ],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("edit-quickfix", options)))
enddef

def kg8m#plugin#fzf#qf#delete(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#util#qf#list(),
    sink:    function("kg8m#util#qf#delete"),
    options: s:common_fzf_options + [
      "--prompt", "Quickfix files to DELETE> ",
      "--no-exit-0",
      "--no-select-1",
    ],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("delete-quickfix", options)))
enddef
