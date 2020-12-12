function kg8m#plugin#molder#configure() abort  " {{{
  let g:molder_show_hidden = v:true

  nmap <Leader>e :edit %:h<Cr>

  augroup my_vimrc  " {{{
    " Cancel molder
    autocmd FileType molder call s:setup_buffer()
  augroup END  " }}}
endfunction  " }}}

function s:setup_buffer() abort  " {{{
  nnoremap <buffer> q     <C-o>
  nnoremap <buffer> <C-c> <C-o>
endfunction  " }}}
