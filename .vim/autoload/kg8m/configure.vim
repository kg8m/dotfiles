function kg8m#configure#backup() abort  " {{{
  set nobackup

  " Double slash:    fullpath like `%home%admin%.vimrc.swp`
  " Single/no slash: only filename like `.vimrc.swp`
  let swapdir = expand("~/tmp/.vimswap//")

  if !isdirectory(swapdir)
    call mkdir(swapdir, "p")
  endif

  let &directory = swapdir
endfunction  " }}}

function kg8m#configure#colors() abort  " {{{
  call kg8m#configure#colors#terminal()
  call kg8m#configure#colors#colorscheme()
  call kg8m#configure#colors#performance()
endfunction  " }}}

function kg8m#configure#column() abort  " {{{
  set number
  set signcolumn=number

  set textwidth=120
  set colorcolumn=+1

  set wrap

  augroup my_vimrc  " {{{
    autocmd FileType markdown,moin set colorcolumn=
  augroup END  " }}}
endfunction  " }}}

function kg8m#configure#completion() abort  " {{{
  set completeopt=menu,menuone,popup,noinsert,noselect
  set pumheight=20

  set wildmenu
  set wildmode=list:longest,full
endfunction  " }}}

function kg8m#configure#cursor() abort  " {{{
  call kg8m#configure#cursor#base()
  call kg8m#configure#cursor#match()
  call kg8m#configure#cursor#highlight()
  call kg8m#configure#cursor#shape()
endfunction  " }}}

function kg8m#configure#folding() abort  " {{{
  call kg8m#configure#folding#global_options()
  call kg8m#configure#folding#local_options()
  call kg8m#configure#folding#mappings()
  call kg8m#configure#folding#manual#setup()
endfunction  " }}}

function kg8m#configure#formatoptions() abort  " {{{
  call kg8m#configure#formatoptions#base()
endfunction  " }}}

function kg8m#configure#indent() abort  " {{{
  call kg8m#configure#indent#base()
  call kg8m#configure#indent#filetypes()
endfunction  " }}}

function kg8m#configure#scroll() abort  " {{{
  set diffopt+=context:10
  set scrolloff=15
endfunction  " }}}

function kg8m#configure#search() abort  " {{{
  set hlsearch
  set incsearch

  set ignorecase
  set smartcase
endfunction  " }}}

function kg8m#configure#statusline() abort  " {{{
  set display+=lastline
  set noshowmode
  set showcmd
endfunction  " }}}

function kg8m#configure#undo() abort  " {{{
  set undofile

  let undodir = expand("~/tmp/.vimundo")

  if !isdirectory(undodir)
    call mkdir(undodir, "p")
  endif

  let &undodir = undodir
endfunction  " }}}

function kg8m#configure#commands() abort  " {{{
  " http://vim-users.jp/2009/05/hack17/
  command! -nargs=1 -complete=file Rename f <args> | call delete(expand("#")) | write

  " Show counts (h v_g_CTRL-G)
  command! -nargs=0 -range Stats call feedkeys("g\<C-g>")
  command! -nargs=0 -range Counts Stats
endfunction  " }}}

function kg8m#configure#mappings() abort  " {{{
  " Time to wait for a key code or mapped key sequence
  set timeoutlen=3000

  call kg8m#configure#mappings#base()
  call kg8m#configure#mappings#search()
  call kg8m#configure#mappings#utils()
  call kg8m#configure#mappings#prevent_unconscious_operation()
endfunction  " }}}

function kg8m#configure#others() abort  " {{{
  set belloff=all
  set hidden
  set list
  set listchars=tab:>\ ,eol:\ ,trail:_,extends:>,precedes:<
  set mouse=
  set restorescreen

  " This defines what bases Vim will consider for numbers when using the `CTRL-A` and `CTRL-X` commands for adding to and
  " subtracting from a number respectively.
  "   octal:    If included, numbers that start with a zero will be considered to be octal. Example: Using CTRL-A on "007"
  "             results in "010".
  "   unsigned: If included, numbers are recognized as unsigned. Thus a leading dash or negative sign won't be considered
  "             as part of the number.
  set nrformats-=octal
  set nrformats+=unsigned

  " ' => Maximum number of previously edited files for which the marks are remembered.
  " < => Maximum number of lines saved for each register.
  " h => Disable the effect of 'hlsearch' when loading the viminfo file.
  " s => Maximum size of an item in Kbyte.
  set viminfo='20,<20,h,s10

  augroup my_vimrc  " {{{
    autocmd BufWritePre * if &filetype ==# "" | filetype detect | endif
  augroup END  " }}}
endfunction  " }}}

function kg8m#configure#gui() abort  " {{{
  set guioptions=none

  " set guifont=Osaka-Mono:h14
  set guifont=SFMono-Regular:h12

  set transparency=20
  set imdisable

  " Always show tabline
  set showtabline=2

  call kg8m#configure#gui#window_size#setup()
endfunction  " }}}

" Called from configurations for some plugins
function kg8m#configure#conceal() abort  " {{{
  set concealcursor=nvic
  set conceallevel=2
endfunction  " }}}
