vim9script

export def OnSource(): void
  # Enable Copilot for Git commit messages.
  # https://github.com/github/copilot.vim/blob/87038123804796ca7af20d1b71c3428d858a9124/autoload/copilot.vim#L125
  g:copilot_filetypes = {
    gitcommit: true,
  }

  g:copilot_no_maps = true

  # https://github.com/github/copilot.vim/blob/87038123804796ca7af20d1b71c3428d858a9124/plugin/copilot.vim#L29
  # https://github.com/github/copilot.vim/blob/87038123804796ca7af20d1b71c3428d858a9124/plugin/copilot.vim#L78-L80
  inoremap <expr> <Leader>c<CR>  copilot#Accept()
  inoremap <expr> <Leader>c<Tab> copilot#Accept()
  inoremap <expr> <Leader>cn     copilot#Next()
  inoremap <expr> <Leader>cp     copilot#Previous()
  inoremap <expr> <Leader>cs     copilot#Suggest()
enddef

export def OnPostSource(): void
  # https://github.com/github/copilot.vim/blob/87038123804796ca7af20d1b71c3428d858a9124/plugin/copilot.vim#L53-L69
  copilot#Init()
  copilot#OnFileType()
enddef
