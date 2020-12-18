vim9script

def kg8m#configure#mappings#base(): void  # {{{
  nnoremap <Leader>v :vsplit<Cr>
  nnoremap <Leader>h :split<Cr>

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
enddef  # }}}

def kg8m#configure#mappings#search(): void  # {{{
  nnoremap <Leader>/ :nohlsearch<Cr>:call kg8m#util#notify_clear_search_highlight()<Cr>
  nnoremap / /\v
enddef  # }}}

def kg8m#configure#mappings#utils(): void  # {{{
  vnoremap <Leader>y "yy:call kg8m#util#remote_copy(@")<Cr>
  vnoremap <Leader>w :call kg8m#util#remove_trailing_whitespaces()<Cr>
enddef  # }}}

# <Nul> == <C-Space>
def kg8m#configure#mappings#prevent_unconscious_operation(): void  # {{{
  inoremap <C-w> <Esc><C-w>
  inoremap <Nul> <C-Space>
  tnoremap <Nul> <C-Space>
  noremap <F1> <Nop>
enddef  # }}}
