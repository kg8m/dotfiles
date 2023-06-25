vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"
import autoload "kg8m/util/qf.vim" as qfUtil

const common_fzf_options = [
  "--preview", printf("preview %s/{}.%s", shellescape(qfUtil.DIRPATH), qfUtil.EXTENSION),
  "--preview-window", "down:75%:wrap:nohidden",
]

export def Load(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  qfUtil.List(),
    sink:    qfUtil.Load,
    options: common_fzf_options + [
      "--prompt", "Quickfix file to load> ",
      "--no-multi",
    ],
  }

  fzf#run(fzf#wrap("load-quickfix", options))
enddef

export def Edit(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  qfUtil.List(),
    sink:    qfUtil.Edit,
    options: common_fzf_options + [
      "--prompt", "Quickfix file to edit> ",
      "--no-multi",
    ],
  }

  fzf#run(fzf#wrap("edit-quickfix", options))
enddef

export def Delete(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  qfUtil.List(),
    sink:    qfUtil.Delete,
    options: common_fzf_options + [
      "--prompt", "Quickfix files to DELETE> ",
      "--no-exit-0",
      "--no-select-1",
    ],
  }

  fzf#run(fzf#wrap("delete-quickfix", options))
enddef

plugin.EnsureSourced("fzf.vim")
