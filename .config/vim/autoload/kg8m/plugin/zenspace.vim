vim9script

export def Configure(): void
  augroup vimrc-plugin-zenspace
    autocmd!
    autocmd ColorScheme * highlight ZenSpace gui=underline guibg=DarkGray guifg=DarkGray
  augroup END

  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source:      () => OnSource(),
    hook_post_source: () => OnPostSource(),
  })
enddef

def OnSource(): void
  g:zenspace#default_mode = "on"
enddef

def OnPostSource(): void
  zenspace#update()
enddef
