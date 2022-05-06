vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

const common_fzf_options = [
  "--preview", printf("preview %s/{}.%s", shellescape(g:kg8m#util#qf#dirpath), kg8m#util#qf#extension),
  "--preview-window", "down:75%:wrap:nohidden",
]

export def Load(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#util#qf#List(),
    sink:    function("kg8m#util#qf#Load"),
    options: common_fzf_options + [
      "--prompt", "Quickfix file to load> ",
      "--no-multi",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("load-quickfix", options)))
enddef

export def Edit(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#util#qf#List(),
    sink:    function("kg8m#util#qf#Edit"),
    options: common_fzf_options + [
      "--prompt", "Quickfix file to edit> ",
      "--no-multi",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("edit-quickfix", options)))
enddef

export def Delete(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  kg8m#util#qf#List(),
    sink:    function("kg8m#util#qf#Delete"),
    options: common_fzf_options + [
      "--prompt", "Quickfix files to DELETE> ",
      "--no-exit-0",
      "--no-select-1",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("delete-quickfix", options)))
enddef
