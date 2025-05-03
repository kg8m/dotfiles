vim9script

import autoload "kg8m/plugin/closetag.vim"
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/string.vim" as stringUtil

final cache = {
  insert_entered_from_blockwise_visual: false,
}

augroup vimrc-plugin-mappings-i
  autocmd!
  # \x16 = <C-v> = blockwise Visual mode
  autocmd ModeChanged [\x16]:i OnInsertEnterFromBlockwiseVisual()
  autocmd InsertLeave *        OnInsertLeave()
augroup END

def OnInsertEnterFromBlockwiseVisual(): void
  cache.insert_entered_from_blockwise_visual = true
enddef

def OnInsertLeave(): void
  cache.insert_entered_from_blockwise_visual = false
enddef

# This function can be called multiple times in order to overwrite plugins’ mappings.
export def Define(options: dict<bool> = {}): void
  if has_key(b:, "is_kg8m_custom_imaps_defined") && get(options, "force", false)
    return
  endif

  if get(b:, "kg8m_custom_imaps_disabled", false)
    return
  endif

  inoremap <buffer><expr>         <Plug>(kg8m-close-popup) ClosePopupExpr()

  # <silent> for lexima#expand’s echo
  inoremap <buffer><expr><silent> <CR> CrExpr()

  imap     <buffer>               <C-h> <BS>

  inoremap <buffer><expr>         <Tab>   TabExpr()
  inoremap <buffer><expr>         <S-Tab> ShiftTabExpr()

  # Insert selected completion candidate word via `<Up>`/`<Down>` keys like `<C-p>`/`<C-n>` keys.
  # <Up>:   Select the previous match, as if CTRL-P was used, but don’t insert it.
  # <Down>: Select the next match, as if CTRL-N was used, but don’t insert it.
  # :h popupmenu-keys
  inoremap <buffer><expr>         <Up>   pumvisible() ? "<C-p>" : "<Up>"
  inoremap <buffer><expr>         <Down> pumvisible() ? "<C-n>" : "<Down>"

  # <silent> for lexima#expand’s echo
  imap     <buffer><expr><silent> > GtExpr()

  b:is_kg8m_custom_imaps_defined = true
enddef

export def Disable(): void
  b:kg8m_custom_imaps_disabled = true
enddef

def ClosePopupExpr(): string
  return pumvisible() ? "\<C-y>" : ""
enddef

def CrExpr(): string
  if neosnippet#expandable_or_jumpable()
    return "\<Plug>(neosnippet_expand_or_jump)"
  elseif vsnip#available(1)
    return "\<Plug>(vsnip-expand-or-jump)"
  else
    # <C-g>u: Break undo sequence when a new line is inserted
    const base = $"\<C-g>u{lexima#expand("<CR>", "i")}"

    if pumvisible()
      return $"\<Plug>(kg8m-close-popup){empty(v:completed_item) ? "" : base}"
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

  if !listUtil.Includes(closetag.FILETYPES, &filetype)
    return ">"
  endif

  if &filetype =~# '\v^(gitcommit|markdown)$'
    # closetag.SHORTCUT_KEY doesn’t work for blockquote markers with blockwise Visual mode.
    if cache.insert_entered_from_blockwise_visual
      return ">"
    else
      return closetag.SHORTCUT_KEY
    endif
  endif

  const context_filetype = context_filetype#get_filetype()

  if context_filetype ==# "html"
    return closetag.SHORTCUT_KEY
  endif

  if context_filetype ==# "eruby" && stringUtil.EndsWith(bufname(), ".html.erb")
    return closetag.SHORTCUT_KEY
  endif

  if &filetype =~# '\v^%(javascript|typescript)'
    const syntax_name = synIDattr(synID(line("."), col(".") - 1, true), "name")

    if syntax_name =~# '\v^jsx%(Braces|ComponentName|String|Tag|TagName)$'
      return closetag.SHORTCUT_KEY
    else
      return ">"
    endif
  endif

  return ">"
enddef

def TabExpr(): string
  if pumvisible()
    return "\<C-n>"
  elseif IsOnIndentation()
    return "\<Tab>"
  else
    # <C-t>: increase indentation
    return "\<C-t>"
  endif
enddef

def ShiftTabExpr(): string
  if pumvisible()
    return "\<C-p>"
  elseif IsOnIndentation()
    return "\<S-Tab>"
  else
    # <C-d>: decrease indentation
    return "\<C-d>"
  endif
enddef

def IsOnIndentation(): bool
  if col(".") ==# 1
    return true
  endif

  const leading_trimmed_text = getline(".")->strpart(0, col(".") - 1)->trim()

  if leading_trimmed_text ==# ""
    return true
  endif

  const syntax_name = synIDattr(synID(line("."), col(".") - 1, true), "name")

  if syntax_name->tolower()->stringUtil.Includes("comment")
    const comment_symbol = substitute(&commentstring, '\s*%s.*$', "", "")

    if leading_trimmed_text ==# comment_symbol
      return true
    endif
  endif

  return false
enddef
