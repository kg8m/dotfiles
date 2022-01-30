vim9script

def kg8m#plugin#zenspace#configure(): void
  augroup vimrc-plugin-zenspace
    autocmd!
    autocmd ColorScheme * highlight ZenSpace gui=underline guibg=DarkGray guifg=DarkGray
  augroup END

  kg8m#plugin#configure({
    lazy:     true,
    on_start: true,
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:on_source(): void
  g:zenspace#default_mode = "on"
enddef

def s:on_post_source(): void
  zenspace#update()
enddef
