function kg8m#plugin#easyalign#configure() abort  " {{{
  vnoremap <Leader>a :EasyAlign<Space>

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: "EasyAlign",
  \ })
endfunction  " }}}
