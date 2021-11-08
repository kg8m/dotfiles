vim9script

augroup my_vimrc
  autocmd InsertEnter                  * timer_start(0, (_) => kg8m#plugin#mappings#i#define())
  autocmd User insert_mode_plugin_loaded timer_start(0, (_) => kg8m#plugin#mappings#i#define())
augroup END

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

def kg8m#configure#mappings#utils(): void
  xnoremap <silent> <Leader>y "zy:call kg8m#util#remote_copy(@z)<CR>
  xnoremap <silent> <Leader>w :call kg8m#util#remove_trailing_whitespaces()<CR>
enddef

# <Nul> == <C-Space>
def kg8m#configure#mappings#prevent_unconscious_operation(): void
  inoremap <C-w> <Esc><C-w>
  inoremap <Nul> <C-Space>
  tnoremap <Nul> <C-Space>
  noremap <F1> <Nop>
enddef
