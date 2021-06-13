vim9script

def kg8m#plugin#mappings#i#define(): void
  imap     <silent><expr> <buffer> <CR> <SID>cr_expr()

  inoremap <silent><expr> <buffer> <BS>  <SID>bs_expr()
  inoremap <silent><expr> <buffer> <C-h> <SID>bs_expr()

  inoremap         <expr> <buffer> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap         <expr> <buffer> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

  # Insert selected completion candidate word via `<Up>`/`<Down>` keys like `<C-p>`/`<C-n>` keys.
  # <Up>:   Select the previous match, as if CTRL-P was used, but don't insert it.
  # <Down>: Select the next match, as if CTRL-N was used, but don't insert it.
  # :h popupmenu-keys
  inoremap         <expr> <buffer> <Up>   pumvisible() ? "\<C-p>" : "\<Up>"
  inoremap         <expr> <buffer> <Down> pumvisible() ? "\<C-n>" : "\<Down>"

  # <silent> for lexima#expand's echo
  imap     <silent><expr> <buffer> > <SID>gt_expr()
enddef

def s:cr_expr(): string
  if neosnippet#expandable_or_jumpable()
    return "\<Plug>(neosnippet_expand_or_jump)"
  elseif vsnip#available(1)
    return "\<Plug>(vsnip-expand-or-jump)"
  else
    if pumvisible()
      return asyncomplete#close_popup()
    else
      # <C-g>u: Break undo sequence when a new line is inserted
      return "\<C-g>u" .. lexima#expand("<CR>", "i")
    endif
  endif
enddef

def s:bs_expr(): string
  return lexima#expand("<BS>", "i") .. kg8m#plugin#completion#refresh()
enddef

def s:gt_expr(): string
  if getline(".")->strpart(col(".") - 1, 1) ==# ">"
    return lexima#expand(">", "i")
  else
    if kg8m#util#list#includes(kg8m#plugin#closetag#filetypes(), &filetype)
      return g:closetag_shortcut
    else
      return ">"
    endif
  endif
enddef
