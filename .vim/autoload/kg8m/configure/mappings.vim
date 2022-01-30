vim9script

augroup vimrc-configure-mappings
  autocmd!
  autocmd InsertEnter                  * timer_start(0, (_) => kg8m#plugin#mappings#i#define())
  autocmd User insert_mode_plugin_loaded timer_start(0, (_) => kg8m#plugin#mappings#i#define({ force: true }))
augroup END

def kg8m#configure#mappings#base(): void
  # Split window
  nnoremap <Leader>v :vsplit<CR>
  nnoremap <Leader>h :split<CR>

  # Overwrite default `f`/`F`/`t`/`T`.
  nnoremap f <Cmd>call kg8m#util#f2#f()<CR>
  xnoremap f <Cmd>call kg8m#util#f2#f()<CR>
  onoremap f <Cmd>call kg8m#util#f2#f()<CR>
  nnoremap F <Cmd>call kg8m#util#f2#F()<CR>
  xnoremap F <Cmd>call kg8m#util#f2#F()<CR>
  onoremap F <Cmd>call kg8m#util#f2#F()<CR>
  nnoremap t <Cmd>call kg8m#util#f2#t()<CR>
  xnoremap t <Cmd>call kg8m#util#f2#t()<CR>
  onoremap t <Cmd>call kg8m#util#f2#t()<CR>
  nnoremap T <Cmd>call kg8m#util#f2#T()<CR>
  xnoremap T <Cmd>call kg8m#util#f2#T()<CR>
  onoremap T <Cmd>call kg8m#util#f2#T()<CR>

  nnoremap <Leader>f <Cmd>call kg8m#util#f2#multiline()<CR>
  xnoremap <Leader>f <Cmd>call kg8m#util#f2#multiline()<CR>
  onoremap <Leader>f <Cmd>call kg8m#util#f2#multiline()<CR>

  # Overwrite default `;`/`,`.
  nnoremap ; <Cmd>call kg8m#util#f2#semi()<CR>
  xnoremap ; <Cmd>call kg8m#util#f2#semi()<CR>
  onoremap ; <Cmd>call kg8m#util#f2#semi()<CR>
  nnoremap , <Cmd>call kg8m#util#f2#comma()<CR>
  xnoremap , <Cmd>call kg8m#util#f2#comma()<CR>
  onoremap , <Cmd>call kg8m#util#f2#comma()<CR>

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
  # <C-g>U: don't break undo with next left/right cursor movement, if the cursor stays within the same line
  inoremap <C-k> <Up>
  inoremap <C-f> <C-g>U<Right>
  inoremap <C-j> <Down>
  inoremap <C-b> <C-g>U<Left>
  inoremap <C-a> <Home>
  inoremap <C-e> <End>
  cnoremap <C-k> <Up>
  cnoremap <C-f> <Right>
  cnoremap <C-j> <Down>
  cnoremap <C-b> <Left>
  cnoremap <C-a> <Home>
  cnoremap <C-e> <End>

  # Replace selected text with unnamed register content without overwriting.
  # :h visual-operators
  #   v_P: put without unnamed register overwrite
  xnoremap r P

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

  nnoremap <silent> m :call kg8m#util#marks#increment()<CR>
enddef

# <Nul> == <C-Space>
def kg8m#configure#mappings#prevent_unconscious_operation(): void
  inoremap <C-w> <Esc><C-w>
  inoremap <Nul> <C-Space>
  tnoremap <Nul> <C-Space>
  noremap <F1> <Nop>
enddef
