function kg8m#util#daemons#setup() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd BufWritePost .eslintrc.*,package.json call kg8m#javascript#restart_eslint_d()
    autocmd BufWritePost .rubocop.yml             call kg8m#ruby#restart_rubocop_daemon()
  augroup END  " }}}
endfunction  " }}}
