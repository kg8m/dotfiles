function kg8m#plugin#splitjoin#configure() abort  " {{{
  nnoremap <Leader>J :SplitjoinJoin<Cr>
  nnoremap <Leader>S :SplitjoinSplit<Cr>

  let g:splitjoin_split_mapping       = ""
  let g:splitjoin_join_mapping        = ""
  let g:splitjoin_ruby_trailing_comma = v:true
  let g:splitjoin_ruby_hanging_args   = v:false

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: ["SplitjoinJoin", "SplitjoinSplit"],
  \ })
endfunction  " }}}
