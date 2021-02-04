vim9script

def kg8m#configure#folding#global_options(): void
  set foldmethod=marker
  set foldopen=hor
  set foldminlines=1
  set foldcolumn=5

  # Don't use `set fillchars=vert:\|` because it raises an error in Vim9 script
  &fillchars = "vert:|"
enddef

def kg8m#configure#folding#local_options(): void
  augroup my_vimrc
    autocmd FileType gitconfig  setlocal foldmethod=indent
    autocmd FileType haml       setlocal foldmethod=indent
    autocmd FileType neosnippet setlocal foldmethod=marker
    autocmd FileType sh,zsh     setlocal foldmethod=syntax
    autocmd FileType gitcommit,qfreplace setlocal nofoldenable
    autocmd BufEnter addp-hunk-edit.diff setlocal nofoldenable
  augroup END
enddef

def kg8m#configure#folding#mappings(): void
  # Frequently used keys:
  #   zo: Open current fold
  #   zc: Close current fold
  #   zR: Open all folds
  #   zM: Close all folds
  #   zx: Recompute all folds
  #   z[: Move to start of current fold
  #   z]: Move to end of current fold
  #   zj: Move to start of next fold
  #   zk: Move to end of previous fold
  noremap z[ [z
  noremap z] ]z
enddef
