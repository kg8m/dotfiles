vim9script

def kg8m#plugin#hitspop#configure(): void  # {{{
  g:hitspop_line       = "winbot"
  g:hitspop_line_mod   = -1
  g:hitspop_column     = "winright"
  g:hitspop_column_mod = -2

  augroup my_vimrc  # {{{
    autocmd User clear_search_highlight hitspop#clean()
  augroup END  # }}}
enddef  # }}}
