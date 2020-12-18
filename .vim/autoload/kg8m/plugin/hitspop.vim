def kg8m#plugin#hitspop#configure(): void  # {{{
  g:hitspop_popup_position = { line: "winbot", col: "winleft" }

  augroup my_vimrc  # {{{
    autocmd User clear_search_highlight hitspop#clean()
  augroup END  # }}}
enddef  # }}}
