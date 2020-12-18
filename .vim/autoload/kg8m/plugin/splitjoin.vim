vim9script

def kg8m#plugin#splitjoin#configure(): void  # {{{
  nnoremap <Leader>J :SplitjoinJoin<Cr>
  nnoremap <Leader>S :SplitjoinSplit<Cr>

  g:splitjoin_split_mapping       = ""
  g:splitjoin_join_mapping        = ""
  g:splitjoin_ruby_trailing_comma = v:true
  g:splitjoin_ruby_hanging_args   = v:false

  kg8m#plugin#configure({
    lazy:   v:true,
    on_cmd: ["SplitjoinJoin", "SplitjoinSplit"],
  })
enddef  # }}}
