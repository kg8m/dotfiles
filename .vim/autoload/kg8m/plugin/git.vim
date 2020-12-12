function kg8m#plugin#git#configure() abort  " {{{
  let g:gitcommit_cleanup = "scissors"

  augroup my_vimrc  " {{{
    " Prevent vim-git from change options, e.g., formatoptions
    autocmd FileType gitcommit let b:did_ftplugin = v:true
  augroup END  " }}}
endfunction  " }}}
