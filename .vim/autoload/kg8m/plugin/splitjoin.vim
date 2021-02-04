vim9script

def kg8m#plugin#splitjoin#configure(): void
  nnoremap <Leader>J :SplitjoinJoin<CR>
  nnoremap <Leader>S :SplitjoinSplit<CR>

  g:splitjoin_split_mapping       = ""
  g:splitjoin_join_mapping        = ""
  g:splitjoin_ruby_trailing_comma = true
  g:splitjoin_ruby_hanging_args   = false

  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: ["SplitjoinJoin", "SplitjoinSplit"],
  })
enddef
