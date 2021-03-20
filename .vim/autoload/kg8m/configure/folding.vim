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

    autocmd FileType * if s:should_disable_folding() | setlocal nofoldenable | endif
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

def s:should_disable_folding(): bool
  # For auto-git-diff
  if kg8m#util#is_git_rebase() && &filetype ==# "diff"
    return true
  endif

  # For diffs of `git commit --verbose` and candidates of qfreplace
  if &filetype =~# '\v^%(gitcommit|qfreplace)$'
    return true
  endif

  # For edit mode of `git add --patch`
  if bufname() ==# "addp-hunk-edit.diff"
    return true
  endif

  return false
enddef
