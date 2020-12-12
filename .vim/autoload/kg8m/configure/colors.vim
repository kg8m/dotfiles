function kg8m#configure#colors#terminal() abort  " {{{
  set termguicolors

  " Black,     Dark Red,     Dark GreeN, Brown,
  " Dark Blue, Dark Magenta, Dark Cyan,  Light GrEy,
  " Dark Grey, Red,          Green,      YellOw,
  " Blue,      Magenta,      Cyan,       White,
  let g:terminal_ansi_colors = [
  \   "#000000", "#EE7900", "#BAED00", "#EBCE00",
  \   "#00BEF3", "#BAA0F0", "#66AED7", "#EAEAEA",
  \   "#333333", "#FF8200", "#C1F600", "#FFE000",
  \   "#00C2F9", "#C6ABFF", "#71C0ED", "#FFFFFF",
  \ ]
endfunction  " }}}

function kg8m#configure#colors#colorscheme() abort  " {{{
  colorscheme molokai
endfunction  " }}}

function kg8m#configure#colors#performance() abort  " {{{
  augroup my_vimrc  " {{{
    " Prevent syntax highlighting from being too slow
    " cf. `:h :syn-sync-maxlines` / `:h :syn-sync-minlines`
    autocmd Syntax * syntax sync minlines=100 maxlines=1000
  augroup END  " }}}

  set maxmempattern=5000
  set redrawtime=5000

  set lazyredraw
  set ttyfast
endfunction  " }}}
