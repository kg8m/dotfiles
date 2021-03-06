vim9script

def kg8m#plugin#histexclude#configure(): void
  g:histexclude = { ":": '\v^[:[:space:]]*(\d+\s*$|w(rite)?!?$|wq!?$|q(uit)?!?$|qa(ll)?!?$)' }

  # Disable because mappings like `q:` by vim-histexclude conflict with my mapping `q`
  g:histexclude_mappings = false

  # https://github.com/itchyny/vim-histexclude/blob/69eb4467f261ed11852c36908c50fb351bafe103/plugin/histexclude.vim#L20
  noremap <expr> : histexclude#update(":")
enddef
