vim9script

def kg8m#plugin#molder#configure(): void  # {{{
  g:molder_show_hidden = v:true

  nmap <Leader>e :edit <C-r>=expand("%")->empty() ? "." : "%:h"<Cr><Cr>

  augroup my_vimrc  # {{{
    # Cancel molder
    autocmd FileType molder s:setup_buffer()
  augroup END  # }}}
enddef  # }}}

def s:setup_buffer(): void  # {{{
  nnoremap <buffer> q     <C-o>
  nnoremap <buffer> <C-c> <C-o>
enddef  # }}}
