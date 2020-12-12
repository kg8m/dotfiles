function kg8m#configure#folding#global_options() abort  " {{{
  set foldmethod=marker
  set foldopen=hor
  set foldminlines=1
  set foldcolumn=5
  set fillchars=vert:\|
endfunction  " }}}

function kg8m#configure#folding#local_options() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd FileType haml       setlocal foldmethod=indent
    autocmd FileType neosnippet setlocal foldmethod=marker
    autocmd FileType sh,zsh     setlocal foldmethod=syntax
    autocmd FileType vim        setlocal foldmethod=marker
    autocmd FileType gitcommit,qfreplace setlocal nofoldenable
    autocmd BufEnter addp-hunk-edit.diff setlocal nofoldenable
  augroup END  " }}}
endfunction  " }}}

function kg8m#configure#folding#mappings() abort  " {{{
  " Frequently used keys:
  "   zo: Open current fold
  "   zc: Close current fold
  "   zR: Open all folds
  "   zM: Close all folds
  "   zx: Recompute all folds
  "   z[: Move to start of current fold
  "   z]: Move to end of current fold
  "   zj: Move to start of next fold
  "   zk: Move to end of previous fold
  noremap z[ [z
  noremap z] ]z
endfunction  " }}}
