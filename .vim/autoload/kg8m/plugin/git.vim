vim9script

def kg8m#plugin#git#configure(): void  # {{{
  g:gitcommit_cleanup = "scissors"

  augroup my_vimrc  # {{{
    # Prevent vim-git from change options, e.g., formatoptions
    autocmd FileType gitcommit b:did_ftplugin = true
  augroup END  # }}}
enddef  # }}}
