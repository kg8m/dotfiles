set nocompatible

let s:PLUGINS_DIRPATH = "/tmp/vim.minimal.dein"
let s:DEIN_REPOSITORY = "Shougo/dein.vim"
let s:DEIN_DIRPATH    = s:PLUGINS_DIRPATH .. "/repos/github.com/" .. s:DEIN_REPOSITORY

if !isdirectory(s:DEIN_DIRPATH)
  call system("git clone https://github.com/" .. s:DEIN_REPOSITORY .. " " .. s:DEIN_DIRPATH)
endif

let &runtimepath ..= "," .. s:DEIN_DIRPATH
call dein#begin(s:PLUGINS_DIRPATH)

" call dein#add(...)

call dein#end()

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif
