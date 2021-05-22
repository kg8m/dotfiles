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

    # Delay to overwrite plugins' configurations
    autocmd FileType * timer_start(100, (_) => s:manage_foldenable())
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
  nnoremap z[ [z
  nnoremap z] ]z
enddef

def s:manage_foldenable(): void
  if s:should_disable()
    setlocal nofoldenable
  endif
enddef

def s:should_disable(): bool
  return (
    # For vimdiff
    &diff ||

    # For auto-git-diff
    (kg8m#util#is_git_rebase() && &filetype ==# "diff") ||

    # For diffs of `git commit --verbose`
    &filetype ==# "gitcommit" ||

    # For candidates of qfreplace
    &filetype ==# "qfreplace" ||

    # For edit mode of `git add --patch`
    kg8m#util#file#current_name() ==# "addp-hunk-edit.diff"
  )
enddef
