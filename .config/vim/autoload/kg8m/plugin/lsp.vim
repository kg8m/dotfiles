vim9script

g:kg8m#plugin#lsp#icons = {
  loading:     "⌛",
  ok:          "✔ ",
  error:       "❌",
  warning:     "⚠️ ",
  information: "ℹ️ ",
  hint:        "💡",
  action:      "🔧",
}

export def OnSource(): void
  g:lsp_diagnostics_echo_cursor                    = false
  g:lsp_diagnostics_enabled                        = true
  g:lsp_diagnostics_float_cursor                   = true
  g:lsp_diagnostics_highlights_insert_mode_enabled = false
  g:lsp_diagnostics_signs_insert_mode_enabled      = false
  g:lsp_diagnostics_virtual_text_enabled           = false  # There are some bugs for multibyte characters.
  g:lsp_fold_enabled                               = false
  g:lsp_inlay_hints_enabled                        = $LSP_INLAY_HINTS_ENABLED ==# "1"  # a little noisy to me
  g:lsp_semantic_enabled                           = $LSP_SEMANTIC_ENABLED ==# "1"     # a little loud to me

  g:lsp_diagnostics_signs_error         = { text: g:kg8m#plugin#lsp#icons.error }
  g:lsp_diagnostics_signs_warning       = { text: g:kg8m#plugin#lsp#icons.warning }
  g:lsp_diagnostics_signs_information   = { text: g:kg8m#plugin#lsp#icons.information }
  g:lsp_diagnostics_signs_hint          = { text: g:kg8m#plugin#lsp#icons.hint }
  g:lsp_document_code_action_signs_hint = { text: g:kg8m#plugin#lsp#icons.action }

  # Prevent signs for code actions from hiding error/warning signs.
  g:lsp_diagnostics_signs_priority     = 10  # (Default)
  g:lsp_diagnostics_signs_priority_map = {
    LspError:   g:lsp_diagnostics_signs_priority + 2,
    LspWarning: g:lsp_diagnostics_signs_priority + 1,
  }

  g:lsp_async_completion = true

  # Usually disable vim-lsp's logging because it makes Vim slower.
  # g:lsp_log_file = expand("~/tmp/vim-lsp.log")

  kg8m#plugin#lsp#popup#Setup()

  augroup vimrc-plugin-lsp
    autocmd!
    autocmd User lsp_setup          kg8m#plugin#lsp#stream#Subscribe()
    autocmd User lsp_buffer_enabled OnLspBufferEnabled()
    autocmd User lsp_server_exit    OnLspBufferEnabled()

    autocmd FileType * ResetTargetBuffer()

    autocmd FileType lsp-quickpick-filter kg8m#plugin#completion#Disable()
    autocmd FileType lsp-quickpick-filter kg8m#plugin#mappings#i#Disable()
  augroup END
enddef

export def IsTargetBuffer(): bool
  if !has_key(b:, "lsp_target_buffer")
    b:lsp_target_buffer = kg8m#util#list#Includes(kg8m#plugin#lsp#servers#Filetypes(), &filetype)
  endif

  return b:lsp_target_buffer
enddef

# cf. OnLspBufferEnabled()
export def IsBufferEnabled(): bool
  if has_key(b:, "lsp_buffer_enabled")
    return true
  else
    return kg8m#plugin#lsp#servers#AreAllRunningOrExited()
  endif
enddef

def OnLspBufferEnabled(): void
  if get(b:, "lsp_buffer_enabled", false)
    return
  endif

  if !kg8m#plugin#lsp#servers#AreAllRunningOrExited()
    return
  endif

  # cf. IsBufferEnabled()
  b:lsp_buffer_enabled = true

  # Lazily set omnifunc to overwrite plugins' configurations.
  SetOmnifunc()
  autocmd InsertEnter <buffer> timer_start(100, (_) => SetOmnifunc())

  nmap <buffer> gd <Plug>(lsp-next-diagnostic)
  nmap <buffer> ge <Plug>(lsp-next-error)
  nmap <buffer> <S-h> <Plug>(lsp-hover)

  if IsDefinitionSupported()
    nmap <buffer> g] <Plug>(lsp-definition)
  endif

  autocmd InsertLeave <buffer> kg8m#plugin#lsp#document_format#OnInsertLeave()
  autocmd TextChanged <buffer> kg8m#plugin#lsp#document_format#OnTextChanged()

  kg8m#events#NotifyAfterLspBufferEnabled()
enddef

def ResetTargetBuffer(): void
  if has_key(b:, "lsp_target_buffer")
    unlet b:lsp_target_buffer
  endif
enddef

def SetOmnifunc(): void
  # Check whether setup of all servers is done or not because this function can be called for a non-target buffer.
  if &omnifunc !=# "lsp#complete" && kg8m#plugin#lsp#servers#AreAllRunningOrExited()
    setlocal omnifunc=lsp#complete
  endif
enddef

def IsDefinitionSupported(): bool
  for server_name in kg8m#plugin#lsp#servers#Names(&filetype)
    var capabilities = lsp#get_server_capabilities(server_name)

    if get(capabilities, "definitionProvider", false)
      return true
    endif
  endfor

  return false
enddef
