set nocompatible

let s:PLUGINS_DIRPATH = "/tmp/vim.minimal.plug"
let s:PLUG_REPOSITORY = "junegunn/vim-plug"
let s:PLUG_DIRPATH    = printf("%s/%s", s:PLUGINS_DIRPATH, fnamemodify(s:PLUG_REPOSITORY, ":t"))

if !isdirectory(s:PLUG_DIRPATH)
  call system(printf("git clone https://github.com/%s %s", s:PLUG_REPOSITORY, s:PLUG_DIRPATH))
  call mkdir(printf("%s/autoload", s:PLUG_DIRPATH), "p")
  call system(printf("ln -s %s/plug.vim %s/autoload/plug.vim", s:PLUG_DIRPATH, s:PLUG_DIRPATH))
endif

let &runtimepath ..= printf(",%s", s:PLUG_DIRPATH)
call plug#begin(s:PLUGINS_DIRPATH)

" Plug 'kg8m/vim-simple-align'

call plug#end()

filetype plugin indent on
syntax enable

if len(filter(values(g:plugs), "!isdirectory(v:val.dir)"))
  PlugInstall
endif
