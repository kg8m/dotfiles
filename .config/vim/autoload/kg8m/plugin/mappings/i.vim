vim9script

# This function can be called multiple times in order to overwrite plugins' mappings.
export def Define(options: dict<bool> = {}): void
  if has_key(b:, "is_defined") && get(options, "force", false)
    return
  endif

  if get(b:, "kg8m_custom_imaps_disabled", false)
    return
  endif

  inoremap <buffer><expr>         . DotExpr()

  # <silent> for lexima#expand's echo
  inoremap <buffer><expr><silent> <CR>                   CrExpr()
  inoremap <buffer><expr><silent> <Plug>(kg8m-i-cr-base) CrExprBase()

  # <silent> for lexima#expand's echo
  inoremap <buffer><expr><silent> <BS>  BsExpr()
  inoremap <buffer><expr><silent> <C-h> BsExpr()

  inoremap <buffer><expr>         <Tab>   TabExpr()
  inoremap <buffer><expr>         <S-Tab> ShiftTabExpr()

  # Insert selected completion candidate word via `<Up>`/`<Down>` keys like `<C-p>`/`<C-n>` keys.
  # <Up>:   Select the previous match, as if CTRL-P was used, but don't insert it.
  # <Down>: Select the next match, as if CTRL-N was used, but don't insert it.
  # :h popupmenu-keys
  inoremap <buffer><expr>         <Up>   pumvisible() ? "<C-p>" : "<Up>"
  inoremap <buffer><expr>         <Down> pumvisible() ? "<C-n>" : "<Down>"

  # <silent> for lexima#expand's echo
  imap     <buffer><expr><silent> > GtExpr()

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
    const base = "\<Plug>(kg8m-i-cr-base)"

    if pumvisible()
      if empty(v:completed_item)
        # Trigger the base `<CR>` expr after closing the popup (basically for breaking the current line).
        # Use timer because `lexima#expand()` doesn't work properly if the popup is visible.
        # Use a silent mapping proxy `<Plug>(kg8m-i-cr-base)` in order to hide `=lexima#insmode#...` on the cmdline.
        timer_start(10, (_) => feedkeys(base))
      endif

      return asyncomplete#close_popup()
    else
      return base
    endif
  endif
enddef

def CrExprBase(): string
  # <C-g>u: Break undo sequence when a new line is inserted
  return "\<C-g>u" .. lexima#expand("<CR>", "i")
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

  if &filetype =~# '\v^(gitcommit|markdown)$'
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

def TabExpr(): string
  if pumvisible()
    return "\<C-n>"
  elseif IsMarkdownListItem()
    # <C-t>: increase indentation
    return "\<C-t>"
  else
    return "\<Tab>"
  endif
enddef

def ShiftTabExpr(): string
  if pumvisible()
    return "\<C-p>"
  elseif IsMarkdownListItem()
    # <C-d>: decrease indentation
    return "\<C-d>"
  else
    return "\<S-Tab>"
  endif
enddef

def IsMarkdownListItem(): bool
  return !!(&filetype =~# '\v^(gitcommit|markdown)$' && getline(".")->trim() =~# '\v^([-*+]|[0-9]+\.)')
enddef
