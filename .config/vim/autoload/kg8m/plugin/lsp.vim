vim9script

import autoload "kg8m/events.vim"
import autoload "kg8m/plugin/completion.vim"
import autoload "kg8m/plugin/lsp/document_format.vim" as documentFormat
import autoload "kg8m/plugin/lsp/popup.vim"
import autoload "kg8m/plugin/lsp/servers.vim"
import autoload "kg8m/plugin/lsp/stream.vim"
import autoload "kg8m/plugin/mappings/i.vim" as mappingsI
import autoload "kg8m/util/list.vim" as listUtil

# https://www.nerdfonts.com/cheat-sheet
export const ICONS = {
  loading:     "󰞌",
  ok:          "",
  error:       "󰚌",
  warning:     "",
  information: "󰋽",
  hint:        "",
  action:      "󰖷",
}

export def OnSource(): void
  # I want to enable vim-lsp manually.
  g:lsp_auto_enable = false

  g:lsp_diagnostics_echo_cursor                      = true
  g:lsp_diagnostics_enabled                          = true
  g:lsp_diagnostics_float_cursor                     = true
  g:lsp_diagnostics_highlights_insert_mode_enabled   = true
  g:lsp_diagnostics_signs_insert_mode_enabled        = true
  g:lsp_diagnostics_virtual_text_align               = "after"
  g:lsp_diagnostics_virtual_text_enabled             = true
  g:lsp_diagnostics_virtual_text_insert_mode_enabled = true
  g:lsp_diagnostics_virtual_text_padding_left        = 5
  g:lsp_diagnostics_virtual_text_prefix              = ">>> "
  g:lsp_diagnostics_virtual_text_wrap                = "truncate"
  g:lsp_fold_enabled                                 = false
  g:lsp_inlay_hints_enabled                          = $LSP_INLAY_HINTS_ENABLED ==# "1"  # a little noisy to me
  g:lsp_semantic_enabled                             = $LSP_SEMANTIC_ENABLED ==# "1"     # a little loud to me

  g:lsp_diagnostics_signs_error         = { text: ICONS.error }
  g:lsp_diagnostics_signs_warning       = { text: ICONS.warning }
  g:lsp_diagnostics_signs_information   = { text: ICONS.information }
  g:lsp_diagnostics_signs_hint          = { text: ICONS.hint }
  g:lsp_document_code_action_signs_hint = { text: ICONS.action }

  # Prevent signs for code actions from hiding error/warning signs.
  g:lsp_diagnostics_signs_priority     = 10  # (Default)
  g:lsp_diagnostics_signs_priority_map = {
    LspError:   g:lsp_diagnostics_signs_priority + 2,
    LspWarning: g:lsp_diagnostics_signs_priority + 1,
  }

  g:lsp_async_completion = true

  # Usually disable vim-lsp’s logging because it makes Vim slower.
  # g:lsp_log_file = expand("~/tmp/vim-lsp.log")

  popup.Setup()

  augroup vimrc-plugin-lsp
    autocmd!
    autocmd User plugin:lsp:source ++once :

    autocmd User lsp_setup          stream.Subscribe()
    autocmd User lsp_buffer_enabled OnLspBufferEnabled()
    autocmd User lsp_server_exit    OnLspBufferEnabled()

    autocmd FileType * ResetTargetBuffer()

    autocmd FileType lsp-quickpick-filter completion.Disable()
    autocmd FileType lsp-quickpick-filter mappingsI.Disable()
  augroup END

  doautocmd <nomodeline> User plugin:lsp:source
enddef

export def IsTargetBuffer(): bool
  if !has_key(b:, "lsp_target_buffer")
    b:lsp_target_buffer = listUtil.Includes(servers.Filetypes(), &filetype)
  endif

  return b:lsp_target_buffer
enddef

# cf. OnLspBufferEnabled()
export def IsBufferEnabled(): bool
  if has_key(b:, "lsp_buffer_enabled")
    return true
  else
    return servers.AreAllRunningOrExited()
  endif
enddef

def OnLspBufferEnabled(): void
  if get(b:, "lsp_buffer_enabled", false)
    return
  endif

  if !servers.AreAllRunningOrExited()
    return
  endif

  # cf. IsBufferEnabled()
  b:lsp_buffer_enabled = true

  # Lazily set omnifunc to overwrite plugins’ configurations.
  SetOmnifunc()
  autocmd InsertEnter <buffer> timer_start(100, (_) => SetOmnifunc())

  nmap <buffer> gd <Plug>(lsp-next-diagnostic)
  nmap <buffer> ge <Plug>(lsp-next-error)
  nmap <buffer> <S-h> <Plug>(lsp-hover)

  const alt_b = "∫"
  const alt_f = "ƒ"
  const alt_j = "∆"
  const alt_k = "˚"
  execute $"nnoremap <buffer><expr> {alt_j} lsp#scroll(+1)"
  execute $"nnoremap <buffer><expr> {alt_k} lsp#scroll(-1)"
  execute $"nnoremap <buffer><expr> {alt_f} lsp#scroll(+5)"
  execute $"nnoremap <buffer><expr> {alt_b} lsp#scroll(-5)"

  if IsDefinitionSupported()
    nmap <buffer> g] <Plug>(lsp-definition)
  endif

  autocmd InsertLeave <buffer> documentFormat.OnInsertLeave()
  autocmd TextChanged <buffer> documentFormat.OnTextChanged()

  events.NotifyAfterLspBufferEnabled()
enddef

def ResetTargetBuffer(): void
  if has_key(b:, "lsp_target_buffer")
    unlet b:lsp_target_buffer
  endif
enddef

def SetOmnifunc(): void
  # Check whether setup of all servers is done or not because this function can be called for a non-target buffer.
  if &omnifunc !=# "lsp#complete" && servers.AreAllRunningOrExited()
    setlocal omnifunc=lsp#complete
  endif
enddef

def IsDefinitionSupported(): bool
  for server_name in servers.Names(&filetype)
    var capabilities = lsp#get_server_capabilities(server_name)

    if get(capabilities, "definitionProvider", false)
      return true
    endif
  endfor

  return false
enddef
