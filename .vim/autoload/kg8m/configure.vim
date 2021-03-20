vim9script

def kg8m#configure#backup(): void
  set nobackup

  # Double slash:    fullpath like `%home%admin%.vimrc.swp`
  # Single/no slash: only filename like `.vimrc.swp`
  const swapdir = expand("~/tmp/.vimswap//")
  mkdir(swapdir, "p")
  &directory = swapdir
enddef

def kg8m#configure#colors(): void
  kg8m#configure#colors#terminal()
  kg8m#configure#colors#colorscheme()
  kg8m#configure#colors#performance()
enddef

def kg8m#configure#column(): void
  set number
  set signcolumn=number

  set textwidth=120
  set colorcolumn=+1

  set wrap

  augroup my_vimrc
    autocmd FileType markdown,moin set colorcolumn=
  augroup END
enddef

def kg8m#configure#completion(): void
  set completeopt=menu,menuone,popup,noinsert,noselect
  set pumheight=20

  set wildmenu
  set wildmode=list:longest,full
enddef

def kg8m#configure#cursor(): void
  kg8m#configure#cursor#base()
  kg8m#configure#cursor#match()
  kg8m#configure#cursor#highlight()
  kg8m#configure#cursor#shape()
enddef

def kg8m#configure#folding(): void
  kg8m#configure#folding#global_options()
  kg8m#configure#folding#local_options()
  kg8m#configure#folding#mappings()
  kg8m#configure#folding#manual#setup()
enddef

def kg8m#configure#formatoptions(): void
  kg8m#configure#formatoptions#base()
enddef

def kg8m#configure#indent(): void
  kg8m#configure#indent#base()
  kg8m#configure#indent#filetypes()
enddef

def kg8m#configure#scroll(): void
  set diffopt+=context:10
  set scrolloff=15
enddef

def kg8m#configure#search(): void
  set hlsearch
  set incsearch

  set ignorecase
  set smartcase
enddef

def kg8m#configure#statusline(): void
  set display+=lastline
  set noshowmode
  set showcmd
enddef

def kg8m#configure#undo(): void
  set undofile

  const undodir = expand("~/tmp/.vimundo")
  mkdir(undodir, "p")
  &undodir = undodir
enddef

def kg8m#configure#commands(): void
  # http://vim-users.jp/2009/05/hack17/
  command! -nargs=1 -complete=file Rename f <args> | delete(expand("#")) | write

  # Show counts
  # :h v_g_CTRL-G
  command! -nargs=0 -range Stats feedkeys("g\<C-g>")
  command! -nargs=0 -range Counts Stats
enddef

def kg8m#configure#mappings(): void
  # Time to wait for a key code or mapped key sequence
  set timeoutlen=3000

  kg8m#configure#mappings#base()
  kg8m#configure#mappings#search()
  kg8m#configure#mappings#utils()
  kg8m#configure#mappings#prevent_unconscious_operation()
enddef

def kg8m#configure#others(): void
  set belloff=all
  set hidden
  set list
  set listchars=tab:>\ ,eol:\ ,trail:_,extends:>,precedes:<
  set mouse=
  set restorescreen

  # This defines what bases Vim will consider for numbers when using the `CTRL-A` and `CTRL-X` commands for adding to and
  # subtracting from a number respectively.
  #   octal:    If included, numbers that start with a zero will be considered to be octal. Example: Using CTRL-A on "007"
  #             results in "010".
  #   unsigned: If included, numbers are recognized as unsigned. Thus a leading dash or negative sign won't be considered
  #             as part of the number.
  set nrformats-=octal
  set nrformats+=unsigned

  # ' => Maximum number of previously edited files for which the marks are remembered.
  # < => Maximum number of lines saved for each register.
  # h => Disable the effect of 'hlsearch' when loading the viminfo file.
  # s => Maximum size of an item in Kbyte.
  set viminfo='20,<20,h,s10

  s:configure_markdown()

  augroup my_vimrc
    autocmd BufWritePre * if &filetype ==# "" | filetype detect | endif

    autocmd BufNewFile,BufRead *.csv          kg8m#util#encoding#edit_with_cp932()
    autocmd BufNewFile,BufRead COMMIT_EDITMSG kg8m#util#encoding#edit_with_utf8()
  augroup END
enddef

def kg8m#configure#gui(): void
  set guioptions=none

  # set guifont=Osaka-Mono:h14
  set guifont=SFMono-Regular:h12

  set transparency=20
  set imdisable

  # Always show tabline
  set showtabline=2

  kg8m#configure#gui#window_size#setup()
enddef

# Called from configurations for some plugins
def kg8m#configure#conceal(): void
  set concealcursor=nvic
  set conceallevel=2
enddef

# https://github.com/tpope/vim-markdown
def s:configure_markdown(): void
  g:markdown_fenced_languages = [
    "css",
    "diff",
    "html",
    "javascript", "js=javascript",
    "ruby", "rb=ruby",
    "sh",
    "sql",
    "vim",
  ]
  g:markdown_syntax_conceal = false
  g:markdown_minlines = 300
enddef
