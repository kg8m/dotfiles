vim9script

import autoload "kg8m/configure/colors.vim"
import autoload "kg8m/configure/comments.vim"
import autoload "kg8m/configure/cursor.vim"
import autoload "kg8m/configure/folding.vim"
import autoload "kg8m/configure/formatoptions.vim"
import autoload "kg8m/configure/indent.vim"
import autoload "kg8m/configure/mappings.vim"
import autoload "kg8m/configure/filetypes.vim"
import autoload "kg8m/util.vim"
import autoload "kg8m/util/encoding.vim" as encodingUtil
import autoload "kg8m/util/qf.vim" as qfUtil
import autoload "kg8m/util/string.vim" as stringUtil
import autoload "kg8m/util/input.vim" as inputUtil

final cache = {}

export def Backup(): void
  set nobackup

  # Double slash:    fullpath like `%home%admin%.vimrc.swp`
  # Single/no slash: only filename like `.vimrc.swp`
  const swapdir = expand("~/tmp/.vimswap//")
  mkdir(swapdir, "p")
  &directory = swapdir

  if util.IsGitCommit()
    # To avoid losing the commit message if `git commit` fails, store a backup here.
    augroup vimrc-configure-backup-git-commit
      autocmd!
      autocmd BufWritePre COMMIT_EDITMSG execute $"write! {expand("%")}.bak"
    augroup END
  endif
enddef

export def Colors(): void
  colors.Terminal()
  colors.Performance()
enddef

export def Column(): void
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

export def Comments(): void
  comments.Base()
enddef

export def Completion(): void
  set completeopt=menu,menuone,popup,noinsert,noselect
  set pumheight=20

  set wildmenu
  set wildmode=longest,full
  set wildoptions=pum
enddef

export def Cursor(): void
  cursor.Base()
  cursor.Match()
  cursor.Highlight()
  cursor.Shape()
enddef

export def Folding(): void
  folding.GlobalOptions()
  folding.LocalOptions()
  folding.Mappings()
  folding.manual#Setup()
enddef

export def Formatoptions(): void
  formatoptions.Base()
enddef

export def Indent(): void
  indent.Base()
  indent.Filetypes()
enddef

export def Scroll(): void
  set diffopt+=context:10
  set scrolloff=15
enddef

export def Search(): void
  set hlsearch
  set incsearch

  set ignorecase
  set smartcase
enddef

export def Statusline(): void
  # Simple default statusline (will be overwritten by lightline)
  # cf. :h 'statusline'
  #   f: Path to the file in the buffer, as typed or relative to current directory.
  #   m: Modified flag, text is "[+]"; "[-]" if 'modifiable' is off.
  #   r: Readonly flag, text is "[RO]".
  #   y: Type of file in the buffer, e.g., "[vim]".  See 'filetype'.
  #   l: Line number.
  #   L: Number of lines in buffer.
  #   c: Column number (byte index).
  #   {: Evaluate expression between '%{' and '}' and substitute result. Note that there is no '%' before the closing
  #      '}'. The expression cannot contain a '}' character, call a function to work around that. See |stl-%{|.
  set statusline=%f\ %m%r%y[%{&fileencoding}][%{&fileformat}][%l/%L,%c]

  # Always show the status line.
  # cf. :h 'laststatus'
  #   0: never
  #   1: only if there are at least two windows
  #   2: always
  set laststatus=2

  set display+=lastline
  set noshowmode
  set showcmd
enddef

export def Undo(): void
  set undofile

  const undodir = expand("~/tmp/.vimundo")
  mkdir(undodir, "p")
  &undodir = undodir
enddef

export def Commands(): void
  # Inspired by http://vim-users.jp/2009/05/hack17/
  command! -nargs=1 -complete=file Rename filecopy(expand("%"), <q-args>) | edit <args> | delete(expand("#"))

  # Show counts
  # :h g_CTRL-G
  # <S-g>$: move to end of buffer
  # g<C-g>: print stats information
  # <C-o>:  go back to previous position
  command! -nargs=0 -range Stats feedkeys(<range> ==# 0 ? "\<S-g>$g\<C-g>\<C-o>" : "\<Esc>gvg\<C-g>")
  command! -nargs=0 -range Counts Stats

  command! -nargs=? -complete=customlist,qfUtil.Complete QfSave   qfUtil.Save(<q-args>)
  command! -nargs=? -complete=customlist,qfUtil.Complete QfLoad   qfUtil.Load(<q-args>)
  command! -nargs=? -complete=customlist,qfUtil.Complete QfEdit   qfUtil.Edit(<q-args>)
  command! -nargs=? -complete=customlist,qfUtil.Complete QfDelete qfUtil.Delete(<q-args>)
enddef

export def Mappings(): void
  # Time to wait for a key code or mapped key sequence
  set timeoutlen=3000

  mappings.Define()
  mappings.PreventUnconsciousOperation()
enddef

export def Others(): void
  language en_US.UTF-8

  # Specify `$TMPDIR` for Vim because macOS sometimes deletes temporary directories (original `$TMPDIR`) even if Vim is
  # using them and breaks Vim.
  $TMPDIR = expand("~/tmp/.vimtmp")
  mkdir($TMPDIR, "p")

  set fileformats=unix,dos,mac

  # :h 'belloff'
  #   all         All events.
  #   backspace   When hitting <BS> or <Del> and deleting results in an error.
  #   cursor      Fail to move around using the cursor keys or <PageUp>/<PageDown> in |Insert-mode|.
  #   complete    Error occurred when using |i_CTRL-X_CTRL-K| or |i_CTRL-X_CTRL-T|.
  #   copy        Cannot copy char from insert mode using |i_CTRL-Y| or |i_CTRL-E|.
  #   ctrlg       Unknown Char after <C-G> in Insert mode.
  #   error       Other Error occurred (e.g. try to join last line) (mostly used in |Normal-mode| or |Cmdline-mode|).
  #   esc         hitting <Esc> in |Normal-mode|.
  #   ex          In |Visual-mode|, hitting |Q| results in an error.
  #   hangul      Ignored.
  #   insertmode  Pressing <Esc> in 'insertmode'.
  #   lang        Calling the beep module for Lua/Mzscheme/TCL.
  #   mess        No output available for |g<|.
  #   showmatch   Error occurred for 'showmatch' function.
  #   operator    Empty region error |cpo-E|.
  #   register    Unknown register after <C-R> in |Insert-mode|.
  #   shell       Bell from shell output |:!|.
  #   spell       Error happened on spell suggest.
  #   term        Bell from |:terminal| output.
  #   wildmode    More matches in |cmdline-completion| available (depends on the 'wildmode' setting).
  set belloff=backspace,cursor,esc,insertmode,shell,term,wildmode

  set diffopt+=algorithm:histogram
  set hidden
  set list
  set listchars=tab:>\ ,eol:\ ,trail:_,extends:>,precedes:<
  set mouse=
  set restorescreen

  # This defines what bases Vim will consider for numbers when using the `CTRL-A` and `CTRL-X` commands for adding to and
  # subtracting from a number respectively.
  #   octal: If included, numbers that start with a zero will be considered to be octal. Example: Using CTRL-A on "007"
  #          results in "010".
  #   blank: If included, treat numbers as signed or unsigned based on preceding whitespace. If a number with a leading
  #          dash has its dash immediately preceded by a non-whitespace character (i.e., not a tab or a " "), the
  #          negative sign won't be considered as part of the number.
  set nrformats-=octal
  set nrformats+=blank

  # ' => Maximum number of previously edited files for which the marks are remembered.
  # < => Maximum number of lines saved for each register.
  # h => Disable the effect of 'hlsearch' when loading the viminfo file.
  # s => Maximum size of an item in Kbyte.
  set viminfo='20,<20,h,s10

  filetypes.Run()

  augroup vimrc-configure-others
    autocmd!
    autocmd BufWritePre * if &filetype ==# "" | filetype detect | endif
    autocmd BufWritePre * MkdirUnlessExist()

    autocmd BufNewFile,BufRead *.csv          encodingUtil.EditWithGuessedEncoding()
    autocmd BufNewFile,BufRead COMMIT_EDITMSG encodingUtil.EditWithUTF8()

    autocmd VimResized * wincmd =
  augroup END
enddef

export def Gui(): void
  set guioptions=

  # SFMonoNF = My SF Mono with Nerd Font
  set guifont=SFMonoNF-Regular:h12

  # Fallback to Migu 1M for Japanese characters. `guifontset` is not available because my MacVim is built without
  # `xfontset` feature. According to help, `guifontwide` is "When not empty, specifies a comma-separated list of fonts
  # to be used for double-width characters."
  # Migu1mNF = My Migu 1m with Nerd Font
  set guifontwide=Migu1mNF-Regular:h12

  set imdisable

  # 0: never
  # 1: only if there are at least two tab pages
  # 2: always
  set showtabline=1
enddef

# Called from configurations for some plugins
export def Conceal(): void
  if get(cache, "is_conceal_configured", false)
    return
  endif

  set concealcursor=nvic
  set conceallevel=2

  g:vim_json_conceal = false

  cache.is_conceal_configured = true
enddef

# https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
def MkdirUnlessExist(): void
  const dirpath = expand("%:p:h")

  if stringUtil.StartsWith(dirpath, "suda://")
    return
  endif

  if !isdirectory(dirpath)
    const prompt = printf("`%s` doesn’t exist. Create?", dirpath)

    if inputUtil.Confirm(prompt)
      mkdir(dirpath, "p")
    endif
  endif
enddef
