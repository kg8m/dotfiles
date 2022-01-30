set nocompatible

let s:PLUGINS_DIRPATH = "/tmp/vim.minimal.dein"
let s:DEIN_REPOSITORY = "Shougo/dein.vim"
let s:DEIN_DIRPATH    = printf("%s/repos/github.com/%s", s:PLUGINS_DIRPATH, s:DEIN_REPOSITORY)

if !isdirectory(s:DEIN_DIRPATH)
  call system(printf("git clone https://github.com/%s %s", s:DEIN_REPOSITORY, s:DEIN_DIRPATH))
endif

let &runtimepath ..= printf(",%s", s:DEIN_DIRPATH)
call dein#begin(s:PLUGINS_DIRPATH)

" call dein#add("kg8m/vim-simple-align")

call dein#end()

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif
