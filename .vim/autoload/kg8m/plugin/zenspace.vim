vim9script

def kg8m#plugin#zenspace#configure(): void
  g:zenspace#default_mode = "on"

  augroup my_vimrc
    autocmd ColorScheme * highlight ZenSpace gui=underline guibg=DarkGray guifg=DarkGray
  augroup END
enddef
