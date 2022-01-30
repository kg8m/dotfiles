vim9script

def kg8m#plugin#histexclude#configure(): void
  nnoremap <expr> : <SID>run()

  kg8m#plugin#configure({
    lazy: true,
    hook_source: () => s:on_source(),
  })
enddef

def s:run(): string
  kg8m#plugin#ensure_sourced("vim-histexclude")

  # https://github.com/itchyny/vim-histexclude/blob/69eb4467f261ed11852c36908c50fb351bafe103/plugin/histexclude.vim#L20
  return histexclude#update(":")
enddef

def s:on_source(): void
  g:histexclude = { ":": '\v^[:[:space:]]*(\d+\s*$|w(rite)?!?$|wq!?$|q(uit)?!?$|qa(ll)?!?$)' }

  # Disable because mappings like `q:` by vim-histexclude conflict with my mapping `q`
  g:histexclude_mappings = false
enddef
