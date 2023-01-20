vim9script

export def Run(): void
  augroup vimrc-configure-filetypes-gitcommit
    autocmd!
    autocmd Syntax gitcommit Syntax()
  augroup END
enddef

def Syntax(): void
  # Overwrite summary width limit. GitHub truncates a summary if it is longer than about 70 width.
  # https://github.com/tpope/vim-git/blob/5143bea9ed17bc32163dbe3ca706344d79507b9d/syntax/gitcommit.vim#L24
  syntax match gitcommitSummary "^.*\%<71v." contained containedin=gitcommitFirstLine nextgroup=gitcommitOverflow contains=@Spell
enddef
