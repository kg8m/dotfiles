vim9script

export def OnSource(): void
  g:fzf_command_prefix = "Fzf"
  g:fzf_buffers_jump   = true
  g:fzf_layout         = { up: "~90%" }
  g:fzf_files_options  = [
    "--preview", "preview {}",
    "--preview-window", "down:75%:wrap:nohidden",
  ]

  # See dwm.vim
  g:fzf_action = { ctrl-o: "DWMOpen" }

  augroup vimrc-plugin-fzf
    autocmd!
    autocmd FileType fzf SetupWindow()
  augroup END
enddef

def SetupWindow(): void
  # Temporarily increase window height
  set winheight=999
  set winheight=1
  redraw
enddef
