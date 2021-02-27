vim9script

def kg8m#plugin#asyncomplete#lsp#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_i:     true,
    on_start: true,
    depends:  "asyncomplete.vim",
  })
enddef
