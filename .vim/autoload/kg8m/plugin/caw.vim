function kg8m#plugin#caw#configure() abort  " {{{
  map gc <Plug>(caw:hatpos:toggle)

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["nv", "<Plug>(caw:"]],
  \   hook_source:      function("s:on_source"),
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

" Overwrite caw.vim's default: https://github.com/tyru/caw.vim/blob/41be34ca231c97d6be6c05e7ecb5b020f79cd37f/after/ftplugin/vim/caw.vim#L5-L9
function s:setup_vim() abort  " {{{
  let b:caw_hatpos_sp  = " "
  let b:caw_zeropos_sp = " "
endfunction  " }}}

function s:on_source() abort  " {{{
  let g:caw_no_default_keymappings = v:true
  let g:caw_hatpos_skip_blank_line = v:true

  augroup my_vimrc  " {{{
    autocmd FileType Gemfile let b:caw_oneline_comment = "#"

    " Delay to overwrite caw.vim's defualt
    autocmd FileType vim call timer_start(100, { -> s:setup_vim() })
  augroup END  " }}}
endfunction  " }}}

function s:on_post_source() abort  " {{{
  if &filetype ==# "vim"
    call s:setup_vim()
  endif
endfunction  " }}}
