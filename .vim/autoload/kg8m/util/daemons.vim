vim9script

def kg8m#util#daemons#setup(): void  # {{{
  augroup my_vimrc  # {{{
    autocmd BufWritePost .eslintrc.*,package.json kg8m#javascript#restart_eslint_d()
    autocmd BufWritePost .rubocop.yml             kg8m#ruby#restart_rubocop_daemon()
  augroup END  # }}}
enddef  # }}}
