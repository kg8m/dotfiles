vim9script

def kg8m#plugin#mappings#define_for_insert_mode(): void
  imap <silent><expr> <CR> <SID>cr_expr_for_insert_mode()

  inoremap <silent><expr> <BS> <SID>bs_expr_for_insert_mode()

  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
enddef

def s:cr_expr_for_insert_mode(): string
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

def s:bs_expr_for_insert_mode(): string
  return lexima#expand("<BS>", "i") .. kg8m#plugin#completion#refresh()
enddef
