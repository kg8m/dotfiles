vim9script

export def GlobalOptions(): void
  set foldmethod=marker
  set foldopen=hor
  set foldminlines=1
  set foldcolumn=5

  # Don't use `set fillchars=vert:\|` because it raises an error in Vim9 script
  &fillchars = "vert:|"

  set fillchars+=diff:/
enddef

export def LocalOptions(): void
  augroup vimrc-configure-folding-local_options
    autocmd!
    autocmd FileType gitconfig  setlocal foldmethod=indent
    autocmd FileType haml       setlocal foldmethod=indent
    autocmd FileType neosnippet setlocal foldmethod=marker

    autocmd FileType * ConfigureFoldenable()
  augroup END
enddef

export def Mappings(): void
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

def ConfigureFoldenable(): void
  if ShouldDisable()
    setlocal nofoldenable
  endif
enddef

def ShouldDisable(): bool
  return (
    # For vimdiff
    &diff ||

    # For auto-git-diff
    (&filetype ==# "diff" && kg8m#util#IsGitRebase()) ||

    # For diffs of `git commit --verbose`
    &filetype ==# "gitcommit" ||

    # For edit mode of `git add --patch`
    kg8m#util#file#CurrentName() ==# "addp-hunk-edit.diff"
  )
enddef
