function kg8m#plugin#hitspop#configure() abort  " {{{
  let g:hitspop_popup_position = #{ line: "winbot", col: "winleft" }

  augroup my_vimrc  " {{{
    autocmd User clear_search_highlight call hitspop#clean()
  augroup END  " }}}
endfunction  " }}}
