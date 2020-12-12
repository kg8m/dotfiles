function kg8m#configure#indent#base() abort  " {{{
  set expandtab
  set noshiftround
  set shiftwidth=2
  set softtabstop=-1
  set tabstop=2

  set autoindent
  set smartindent

  set fixendofline
endfunction  " }}}

function kg8m#configure#indent#filetypes() abort  " {{{
  let g:html_indent_script1 = "inc"
  let g:html_indent_style1  = "inc"

  " :h ft-vim-indent
  let g:vim_indent_cont = 0

  augroup my_vimrc  " {{{
    autocmd FileType neosnippet set noexpandtab
    autocmd FileType text,markdown,moin setlocal cinkeys-=:
  augroup END  " }}}
endfunction  " }}}
