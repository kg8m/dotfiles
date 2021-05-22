vim9script

var s:is_clear_hlsearch_initialized = false

def kg8m#configure#mappings#base(): void
  # Split window
  nnoremap <Leader>v :vsplit<CR>
  nnoremap <Leader>h :split<CR>

  # See also settings of vim-lsp and vim-fzf-tjump
  # <C-t>: Jump back
  nnoremap g[ <C-t>

  # gF: Same as "gf", except if a number follows the file name, then the cursor is positioned on that line in the file.
  # Don't use `nnoremap` because `gf` sometimes overwritten by plugins
  nmap gf gF

  # Increment/Decrement
  nmap + <C-a>
  nmap - <C-x>

  # Swap <C-n>/<C-p> and <Up>/<Down> in commandline mode
  # Original <Up>/<Down> respect inputted prefix
  cnoremap <C-p> <Up>
  cnoremap <C-n> <Down>
  cnoremap <Up>   <C-p>
  cnoremap <Down> <C-n>

  # Swap pasting with adjusting indentations or not
  # Disable exchanging because indentation is sometimes bad
  # nnoremap p ]p
  # nnoremap <S-p> ]<S-p>
  # nnoremap ]p p
  # nnoremap ]<S-p> <S-p>

  # Moving in INSERT mode
  inoremap <C-k> <Up>
  inoremap <C-f> <Right>
  inoremap <C-j> <Down>
  inoremap <C-b> <Left>
  inoremap <C-a> <Home>
  inoremap <C-e> <End>
  cnoremap <C-k> <Up>
  cnoremap <C-f> <Right>
  cnoremap <C-j> <Down>
  cnoremap <C-b> <Left>
  cnoremap <C-a> <Home>
  cnoremap <C-e> <End>

  # v_o: Go to other end of highlighted text
  # Invert visual selection start and end => !
  xnoremap ! o

  # Clear and redraw the screen even if Insert mode
  inoremap <C-l> <C-o><C-l>

  # Select text with quotation marks without spaces around them
  # :h v_iquote
  onoremap a" 2i"
  onoremap a' 2i'
  onoremap a` 2i`
enddef

def kg8m#configure#mappings#search(): void
  nnoremap <expr> <Leader>/ <SID>clear_hlsearch()
  nnoremap <expr> /         <SID>enter_search()
  cnoremap <expr> <C-c>     <SID>exit_cmdline()
enddef

def kg8m#configure#mappings#utils(): void
  xnoremap <Leader>y "zy:call kg8m#util#remote_copy(@")<CR>
  xnoremap <Leader>w :call kg8m#util#remove_trailing_whitespaces()<CR>
enddef

# <Nul> == <C-Space>
def kg8m#configure#mappings#prevent_unconscious_operation(): void
  inoremap <C-w> <Esc><C-w>
  inoremap <Nul> <C-Space>
  tnoremap <Nul> <C-Space>
  noremap <F1> <Nop>
enddef

def s:clear_hlsearch(): string
  if !s:is_clear_hlsearch_initialized
    augroup my_vimrc
      autocmd User clear_search_highlight silent
    augroup END

    s:is_clear_hlsearch_initialized = true
  endif

  const clear        = ":nohlsearch\<CR>"
  const notify       = ":doautocmd <nomodeline> User clear_search_highlight\<CR>"
  const clear_status = ":echo ''\<CR>"

  return clear .. notify .. clear_status
enddef

def s:enter_search(): string
  const enable_highlight      = ":set hlsearch\<CR>"
  const enter_with_very_magic = "/\\v"

  return enable_highlight .. enter_with_very_magic
enddef

def s:exit_cmdline(): string
  const original = "\<C-c>"

  var extra = ""

  if getcmdtype() ==# "/"
    # Call s:clear_hlsearch
    extra = ":call feedkeys('" .. g:mapleader .. "/')\<CR>"
  endif

  return original .. extra
enddef
