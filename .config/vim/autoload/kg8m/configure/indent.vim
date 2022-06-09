vim9script

export def Base(): void
  set expandtab
  set noshiftround
  set shiftwidth=2
  set softtabstop=-1
  set tabstop=2

  set autoindent
  set smartindent

  set nobreakindent
  &showbreak = "↪ "

  set fixendofline
enddef

export def Filetypes(): void
  g:html_indent_script1 = "inc"
  g:html_indent_style1  = "inc"

  # :h ft-vim-indent
  g:vim_indent_cont = 0

  augroup vimrc-configure-indent-filetypes
    autocmd!
    autocmd FileType gitconfig,neosnippet setlocal noexpandtab
    autocmd FileType gitcommit,markdown,moin,text setlocal cinkeys-=:
  augroup END
enddef
