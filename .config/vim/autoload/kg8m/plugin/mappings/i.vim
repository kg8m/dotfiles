vim9script

# This function can be called multiple times in order to overwrite plugins' mappings.
export def Define(options: dict<bool> = {}): void
  if has_key(b:, "is_defined") && get(options, "force", false)
    return
  endif

  if get(b:, "kg8m_custom_imaps_disabled", false)
    return
  endif

  inoremap <buffer><expr>         . <SID>DotExpr()

  # <silent> for lexima#expand's echo
  imap     <buffer><expr><silent> <CR> <SID>CrExpr()

  # <silent> for lexima#expand's echo
  inoremap <buffer><expr><silent> <BS>  <SID>BsExpr()
  inoremap <buffer><expr><silent> <C-h> <SID>BsExpr()

  inoremap <buffer><expr>         <Tab>   pumvisible() ? "<C-n>" : "<Tab>"
  inoremap <buffer><expr>         <S-Tab> pumvisible() ? "<C-p>" : "<S-Tab>"

  # Insert selected completion candidate word via `<Up>`/`<Down>` keys like `<C-p>`/`<C-n>` keys.
  # <Up>:   Select the previous match, as if CTRL-P was used, but don't insert it.
  # <Down>: Select the next match, as if CTRL-N was used, but don't insert it.
  # :h popupmenu-keys
  inoremap <buffer><expr>         <Up>   pumvisible() ? "<C-p>" : "<Up>"
  inoremap <buffer><expr>         <Down> pumvisible() ? "<C-n>" : "<Down>"

  # <silent> for lexima#expand's echo
  imap     <buffer><expr><silent> > <SID>GtExpr()

  b:is_defined = true
enddef

export def Disable(): void
  b:kg8m_custom_imaps_disabled = true
enddef

def DotExpr(): string
  if &omnifunc ==# "lsp#complete"
    return ".\<C-x>\<C-o>"
  else
    return "."
  endif
enddef

def CrExpr(): string
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

def BsExpr(): string
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

def GtExpr(): string
  const following_character = getline(".")->strpart(col(".") - 1, 1)

  if following_character ==# ">"
    return lexima#expand(">", "i")
  endif

  if !kg8m#util#list#Includes(g:kg8m#plugin#closetag#filetypes, &filetype)
    return ">"
  endif

  if &filetype ==# "markdown"
    # Don't overwrite while writing blockquote markers.
    const leading_text = getline(".")->strpart(0, col(".") - 1)

    if leading_text =~# '^\s*$'
      return ">"
    else
      return g:closetag_shortcut
    endif
  endif

  const context_filetype = context_filetype#get_filetype()

  if context_filetype ==# "html"
    return g:closetag_shortcut
  endif

  if context_filetype ==# "eruby" && kg8m#util#string#EndsWith(bufname(), ".html.erb")
    return g:closetag_shortcut
  endif

  if &filetype =~# '\v^%(javascript|typescript)'
    const syntax_name = synIDattr(synID(line("."), col(".") - 1, true), "name")

    if syntax_name =~# '\v^jsx%(Braces|ComponentName|String|Tag|TagName)$'
      return g:closetag_shortcut
    else
      return ">"
    endif
  endif

  return ">"
enddef