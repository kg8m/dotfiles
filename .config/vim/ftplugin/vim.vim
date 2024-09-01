if getline(1) ==# "vim9script"
  " vim-language-server dones’t work for Vim9 script and some completion engines doesn’t work if `:` is contained.
  setlocal iskeyword-=:
else
  " Prevent vim-language-server from completing a function with duplicated `s:` prefix.
  setlocal iskeyword+=:
endif
