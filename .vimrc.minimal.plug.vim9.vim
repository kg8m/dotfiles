vim9script

const PLUGINS_DIRPATH = "/tmp/vim.minimal.plug"
const PLUG_REPOSITORY = "junegunn/vim-plug"
const PLUG_DIRPATH    = printf("%s/%s", PLUGINS_DIRPATH, fnamemodify(PLUG_REPOSITORY, ":t"))

if !isdirectory(PLUG_DIRPATH)
  system(printf("git clone https://github.com/%s %s", PLUG_REPOSITORY, PLUG_DIRPATH))
  mkdir(printf("%s/autoload", PLUG_DIRPATH), "p")
  system(printf("ln -s %s/plug.vim %s/autoload/plug.vim", PLUG_DIRPATH, PLUG_DIRPATH))
endif

&runtimepath ..= printf(",%s", PLUG_DIRPATH)
plug#begin(PLUGINS_DIRPATH)

# Plug 'kg8m/vim-simple-align'

plug#end()

filetype plugin indent on
syntax enable

if len(filter(values(g:plugs), "!isdirectory(v:val.dir)"))
  PlugInstall
endif
