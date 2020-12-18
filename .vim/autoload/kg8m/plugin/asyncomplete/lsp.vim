vim9script

def kg8m#plugin#asyncomplete#lsp#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy:      v:true,
    on_source: "asyncomplete.vim",
  })
enddef  # }}}
