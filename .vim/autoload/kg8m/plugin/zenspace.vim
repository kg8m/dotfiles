function kg8m#plugin#zenspace#configure() abort  " {{{
  let g:zenspace#default_mode = "on"

  augroup my_vimrc  " {{{
    autocmd ColorScheme * highlight ZenSpace term=underline cterm=underline gui=underline ctermbg=DarkGray guibg=DarkGray ctermfg=DarkGray guifg=DarkGray
  augroup END  " }}}
endfunction  " }}}
