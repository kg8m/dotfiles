vim9script

def kg8m#configure#indent#base(): void
  set expandtab
  set noshiftround
  set shiftwidth=2
  set softtabstop=-1
  set tabstop=2

  set autoindent
  set smartindent

  set fixendofline
enddef

def kg8m#configure#indent#filetypes(): void
  g:html_indent_script1 = "inc"
  g:html_indent_style1  = "inc"

  # :h ft-vim-indent
  g:vim_indent_cont = 0

  augroup my_vimrc
    autocmd FileType gitconfig,neosnippet set noexpandtab
    autocmd FileType text,markdown,moin setlocal cinkeys-=:
  augroup END
enddef
