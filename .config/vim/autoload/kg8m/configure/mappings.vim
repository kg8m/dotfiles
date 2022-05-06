vim9script

augroup vimrc-configure-mappings
  autocmd!
  autocmd InsertEnter                  * timer_start(0, (_) => kg8m#plugin#mappings#i#Define())
  autocmd User insert_mode_plugin_loaded timer_start(0, (_) => kg8m#plugin#mappings#i#Define({ force: true }))
augroup END

export def Base(): void
  # Split window
  nnoremap <Leader>v :vsplit<CR>
  nnoremap <Leader>h :split<CR>

  # Overwrite default `f`/`F`/`t`/`T`.
  nnoremap f <Cmd>call kg8m#util#f2#LowerF()<CR>
  xnoremap f <Cmd>call kg8m#util#f2#LowerF()<CR>
  onoremap f <Cmd>call kg8m#util#f2#LowerF()<CR>
  nnoremap F <Cmd>call kg8m#util#f2#UpperF()<CR>
  xnoremap F <Cmd>call kg8m#util#f2#UpperF()<CR>
  onoremap F <Cmd>call kg8m#util#f2#UpperF()<CR>
  nnoremap t <Cmd>call kg8m#util#f2#LowerT()<CR>
  xnoremap t <Cmd>call kg8m#util#f2#LowerT()<CR>
  onoremap t <Cmd>call kg8m#util#f2#LowerT()<CR>
  nnoremap T <Cmd>call kg8m#util#f2#UpperT()<CR>
  xnoremap T <Cmd>call kg8m#util#f2#UpperT()<CR>
  onoremap T <Cmd>call kg8m#util#f2#UpperT()<CR>

  nnoremap <Leader>f <Cmd>call kg8m#util#f2#Multiline()<CR>
  xnoremap <Leader>f <Cmd>call kg8m#util#f2#Multiline()<CR>
  onoremap <Leader>f <Cmd>call kg8m#util#f2#Multiline()<CR>

  # Overwrite default `;`/`,`.
  nnoremap ; <Cmd>call kg8m#util#f2#Semi()<CR>
  xnoremap ; <Cmd>call kg8m#util#f2#Semi()<CR>
  onoremap ; <Cmd>call kg8m#util#f2#Semi()<CR>
  nnoremap , <Cmd>call kg8m#util#f2#Comma()<CR>
  xnoremap , <Cmd>call kg8m#util#f2#Comma()<CR>
  onoremap , <Cmd>call kg8m#util#f2#Comma()<CR>

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

  # For Cmdline popupmenu (`set wildoptions=pum`). Don't do `cnoremap <expr> <Esc> pumvisible() ? "<C-e> : ...`
  # because the mapping to `<Esc>` breaks some operations in Cmdline mode, e.g., pasting from clipboard.
  cnoremap <expr> <CR> pumvisible() ? "<C-y>" : "<CR>"

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

export def Utils(): void
  xnoremap <silent> <Leader>y "zy:call kg8m#util#RemoteCopy(@z)<CR>
  xnoremap <silent> <Leader>w :call kg8m#util#RemoveTrailingWhitespaces()<CR>

  nnoremap <silent> m :call kg8m#util#marks#Increment()<CR>
enddef

# <Nul> == <C-Space>
export def PreventUnconsciousOperation(): void
  inoremap <C-w> <Esc><C-w>
  inoremap <Nul> <C-Space>
  tnoremap <Nul> <C-Space>
  noremap <F1> <Nop>
enddef
