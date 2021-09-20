vim9script

def kg8m#plugin#asyncomplete#lsp#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  "asyncomplete.vim",
  })
enddef
