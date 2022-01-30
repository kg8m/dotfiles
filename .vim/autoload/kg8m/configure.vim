vim9script

final s:cache = {}

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
  kg8m#configure#colors#performance()
enddef

def kg8m#configure#column(): void
  set number
  set signcolumn=number

  set textwidth=120
  set colorcolumn=+1

  set wrap

  augroup vimrc-configure-column
    autocmd!
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
  # Execute `:edit` to record as a MRU file
  command! -nargs=1 -complete=file Rename f <args> | delete(expand("#")) | write | edit

  # Show counts
  # :h g_CTRL-G
  # <S-g>$: move to end of buffer
  # g<C-g>: print stats information
  # <C-o>:  go back to previous position
  command! -nargs=0 -range Stats feedkeys("\<S-g>$g\<C-g>\<C-o>")
  command! -nargs=0 -range Counts Stats

  command! -nargs=? -complete=customlist,kg8m#util#qf#complete QfSave   kg8m#util#qf#save(<q-args>)
  command! -nargs=? -complete=customlist,kg8m#util#qf#complete QfLoad   kg8m#util#qf#load(<q-args>)
  command! -nargs=? -complete=customlist,kg8m#util#qf#complete QfEdit   kg8m#util#qf#edit(<q-args>)
  command! -nargs=? -complete=customlist,kg8m#util#qf#complete QfDelete kg8m#util#qf#delete(<q-args>)
enddef

def kg8m#configure#mappings(): void
  # Time to wait for a key code or mapped key sequence
  set timeoutlen=3000

  kg8m#configure#mappings#base()
  kg8m#configure#mappings#utils()
  kg8m#configure#mappings#prevent_unconscious_operation()
  kg8m#configure#mappings#batch_cursor_move#define()
  kg8m#configure#mappings#search#define()
enddef

def kg8m#configure#others(): void
  set fileformats=unix,dos,mac

  s:configure_ambiwidth()

  set belloff=all
  set diffopt+=algorithm:histogram
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

  kg8m#configure#filetypes#c#run()
  kg8m#configure#filetypes#go#run()
  kg8m#configure#filetypes#markdown#run()

  augroup vimrc-configure-others
    autocmd!
    autocmd BufWritePre * if &filetype ==# "" | filetype detect | endif
    autocmd BufWritePre * s:mkdir_unless_exist()

    autocmd BufNewFile,BufRead *.csv          kg8m#util#encoding#edit_with_cp932()
    autocmd BufNewFile,BufRead COMMIT_EDITMSG kg8m#util#encoding#edit_with_utf8()
  augroup END
enddef

def kg8m#configure#gui(): void
  set guioptions=none

  # set guifont=Osaka-Mono:h14
  set guifont=SFMono-Regular:h12

  # Fallback to Migu 1M for Japanese characters. `guifontset` is not available because my MacVim is built without
  # `xfontset` feature. According to help, `guifontwide` is "When not empty, specifies a comma-separated list of fonts
  # to be used for double-width characters."
  set guifontwide=migu-1m-regular:h12

  set imdisable

  # 0: never
  # 1: only if there are at least two tab pages
  # 2: always
  set showtabline=1
enddef

# Called from configurations for some plugins
def kg8m#configure#conceal(): void
  if get(s:cache, "is_conceal_configured", false)
    return
  endif

  set concealcursor=nvic
  set conceallevel=2

  g:vim_json_conceal = false

  s:cache.is_conceal_configured = true
enddef

def s:configure_ambiwidth(): void
  # Basically treat ambiwidth characters as double width for basic text editing especially Japanese text. Make some
  # ambiwidth characters more readable. Prevent an ambiwidth character from being overlapped by its next character.
  set ambiwidth=double

  # Treat some ambiwidth characters as single width for tools which use ambiwidth borders.
  # cf. https://www.ssec.wisc.edu/~tomw/java/unicode.html
  setcellwidths([
    [0x2500, 0x257f, 1],  # Box Drawing
    [0x2580, 0x259f, 1],  # Block Elements
  ])
enddef

# https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
def s:mkdir_unless_exist(): void
  const dirpath = expand("%:p:h")

  if kg8m#util#string#starts_with(dirpath, "suda://")
    return
  endif

  if !isdirectory(dirpath)
    if input(printf("`%s` doesn't exist. Create? [y/n] ", dirpath)) =~? '^y'
      mkdir(dirpath, "p")
    endif
  endif
enddef
