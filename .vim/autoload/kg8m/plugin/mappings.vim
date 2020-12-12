function kg8m#plugin#mappings#define_cr_for_insert_mode() abort  " {{{
  imap <silent><expr> <Cr> <SID>cr_expr_for_insert_mode()
endfunction  " }}}

function kg8m#plugin#mappings#define_bs_for_insert_mode() abort  " {{{
  inoremap <silent><expr> <BS> <SID>bs_expr_for_insert_mode()
endfunction  " }}}

function kg8m#plugin#mappings#define_tab_for_insert_mode() abort  " {{{
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
endfunction  " }}}

function s:cr_expr_for_insert_mode() abort  " {{{
  if neosnippet#expandable_or_jumpable()
    return "\<Plug>(neosnippet_expand_or_jump)"
  elseif vsnip#available(1)
    return "\<Plug>(vsnip-expand-or-jump)"
  else
    if pumvisible()
      return asyncomplete#close_popup()
    else
      return lexima#expand("<Cr>", "i")
    endif
  endif
endfunction  " }}}

function s:bs_expr_for_insert_mode() abort  " {{{
  return lexima#expand("<BS>", "i")..kg8m#plugin#completion#refresh()
endfunction  " }}}
