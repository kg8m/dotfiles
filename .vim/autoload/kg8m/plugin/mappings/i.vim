vim9script

# Call this function multiple times for overwriting plugins' mappings.
def kg8m#plugin#mappings#i#define(options: dict<bool> = {}): void
  if has_key(b:, "is_defined") && get(options, "force", false)
    return
  endif

  if get(b:, "kg8m_custom_imaps_disabled", false)
    return
  endif

  inoremap         <expr> <buffer> . <SID>dot_expr()

  # <silent> for lexima#expand's echo
  imap     <silent><expr> <buffer> <CR> <SID>cr_expr()

  # <silent> for lexima#expand's echo
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

  b:is_defined = true
enddef

def kg8m#plugin#mappings#i#disable(): void
  b:kg8m_custom_imaps_disabled = true
enddef

def s:dot_expr(): string
  if &omnifunc ==# "lsp#complete"
    return ".\<C-x>\<C-o>"
  else
    return "."
  endif
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
  const base = lexima#expand("<BS>", "i")

  if &omnifunc ==# ""
    return base
  else
    const prev_char = strpart(getline("."), col(".") - 3, 1)

    if prev_char ==# "."
      return base .. "\<C-x>\<C-o>"
    else
      return base
    endif
  endif
enddef

def s:gt_expr(): string
  if getline(".")->strpart(col(".") - 1, 1) ==# ">"
    return lexima#expand(">", "i")
  else
    if kg8m#util#list#includes(g:kg8m#plugin#closetag#filetypes, &filetype)
      const leading_text = getline(".")->strpart(0, col(".") - 1)

      # Don't overwrite while writing blockquote markers
      if &filetype ==# "markdown" && leading_text =~# '^\s*$'
        return ">"
      else
        return g:closetag_shortcut
      endif
    else
      return ">"
    endif
  endif
enddef
