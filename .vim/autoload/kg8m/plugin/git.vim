vim9script

def kg8m#plugin#git#configure(): void
  augroup vimrc-plugin-git
    autocmd!

    # Prevent vim-git from change options, e.g., formatoptions
    autocmd FileType gitcommit b:did_ftplugin = true
  augroup END
enddef
