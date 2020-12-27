vim9script

def kg8m#plugin#easyalign#configure(): void  # {{{
  vnoremap <Leader>a :EasyAlign<Space>

  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: "EasyAlign",
  })
enddef  # }}}
